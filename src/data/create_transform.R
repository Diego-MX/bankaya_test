
# Diego Villamil
# CDMX, September 20th, 2020

library(feather)
library(glue)
# This package allows to include variables in string.  
# Just as Pythons f"...{var}..." formatting strings. 


connect_postgres <- function () {
  conn <- dbConnect(Postgres(),
    dbname   = Sys.getenv("PSQL_BASE"),
    host     = Sys.getenv("PSQL_HOST"),
    user     = Sys.getenv("PSQL_USER"),
    password = Sys.getenv("PSQL_PASS"))
  return (conn)
}


download_loans_customers <- function (store_at) {
  
  loans_loc <- store_at["loans"]
  download.file("https://www.kaggle.com/zhijinzhai/loandata/download", 
                glue("{loans_loc}.zip"))
  
  unzip(glue("{loans_loc}.zip"), exdir=loans_loc, unzip="unzip")
  if (!file.exists(loans_loc)) {
    stop ("Data wasn't unzipped, please extract manually.") }
  
  
  customers_loc <- store_at["customers"]
  download.file("https://www.briandunning.com/sample-data/us-500.zip", 
                glue("{customers_loc}.zip"))
  
  unzip(glue("{customers_loc}.zip"), exdir=customers_loc, unzip="unzip")
  if (!file.exists(customers_loc)) {
    stop ("Data wasn't unzipped, please extract manually.") }

}
  

sample_dates <- function (between, size) {
  width <- (between[2] - between[1]) %>% as.numeric()
  smpl_ints <- sample(width, size, TRUE)
  smpl_dts <- between[1] + smpl_ints
  return (smpl_dts)
}


get_customers_and_addresses <- function (n, age_ref) {
  if (n > 500) warning (
    "Please choose n <= 500, or setup dataset from another sample.")
  
  if (missing(age_ref)) age_ref <- today()
  
  dob_begin = age_ref - years(65)
  dob_end   = age_ref - years(18)
  
  selection <- read_csv(glue("{customers_loc}/us-500.csv"), 
        col_types = cols()) %>% 
    slice(1:n) 
  
  customers_df <- transmute(selection,
    id           = 1:n, 
    name         = first_name, 
    surname      = last_name, 
    birthdate    = sample_dates(c(dob_begin, dob_end), n), 
    main_address = 1:n, 
    phone_number = phone1, 
    payment_coef = runif(n, 0.5, 1),
    update_dt    = now()) 
  
  parse_address <- selection$address %>% 
    str_match("^([0-9]*) ([a-z A-Z0-9]*)( #.*)?$") %>% # This is a matrix
    {.[, 2:4]} %>% 
    set_colnames(c("street_number", "street", "interior")) %>% 
    as_tibble() %>% 
    mutate(interior = str_replace(interior, " #", "")) %>% 
    select(2, 1, 3)
  
  random_zipcodes_0 <- sample(selection$zip, 15, FALSE)
  random_zipcodes_n <- sample(random_zipcodes_0, n, TRUE)
  
  addresses_df <- transmute(selection, 
      id           = 1:n, 
      customer_id  = 1:n, 
      neighborhood = county, 
      state        = state, 
      zipcode      = zip, 
      city         = city) %>% 
    mutate(zipcode = random_zipcodes_n, 
      address_type = "residence", 
      update_dt    = now()) %>% 
    bind_cols(parse_address) %>% 
    select(1:2, 9:11, 3:8) 
  
  matched_dfs <- list("customers" = customers_df, 
                      "addresses" = addresses_df)
  return (matched_dfs)
}


get_loans <- function (n, k, within) {
  # N is the number of loans
  # K is the number of customers
  # WITHIN is a date range for starting the loans. 
  
  if (missing(within)) within <- c(today(), today() - years(1))
  
  products <- read_csv("../references/data/loan_products.csv", 
    col_types = cols())
  
  product_rates <- select(products, id, interest_rate)
  
  loans_1 <- read_csv(glue("{loans_loc}/Loan payments data.csv"), 
        col_types = cols()) 
  
  set.seed(42)
  loans_0 <- transmute(loans_1, 
    id           = 1:n, 
    customer_id  = sample(k, size=n, replace=TRUE), 
    loan_product = sample(length(product_rates), size=n, replace=TRUE), 
    start_date   = sample_dates(c(loans_begin, loans_end), 500), 
    end_date     = start_date + months(terms), 
    principal    = Principal, # payment_amount, 
    installments = terms, 
    status       = NA %>% as.character(), 
    balance      = NA %>% as.numeric(), 
    update_dt    = now()) 

  loans_df <- loans_0 %>% 
    left_join(product_rates, by=c("loan_product" = "id")) %>% 
    mutate(
        payment_amount = principal*(1 + interest_rate)/installments) %>% 
    select(1:6, 12, 7:10) # Payment_Amount goes in position 7, not 12. 
  
  and_products <- list("loans" = loans_df, "loan_products" = products)
  return (and_products)
}


simulate_payments <- function (loans, cut_date) {
  if (not("payment_coef" %>% is_in(names(loans)))) stop (
    "LOANS dataframe must be supplied with PAYMENT_COEF column.")
  
  .one_loan_payments <- function (loan_id, start_date, 
        payment_amount, installments, payment_coef) {
    k <- installments
    pymnts_0 <- tibble(
      installment = 1:k,  
      due_date    = start_date + months(1:k), 
      success     = rbernoulli(k, payment_coef)) 
    
    pymnts_df <- mutate(pymnts_0,
      loan_id        = loan_id, 
      due_amount     = payment_amount, 
      applied_amount = if_else(success, due_amount, 0),
      applied_date   = if_else(success, due_date, as.Date(NA)), 
      status         = if_else(success, "complete", "missed")) %>% 
      select(loan_id, due_amount, due_date, 
          applied_amount, applied_date, installment, status)
    return (pymnts_df) 
  }
  
  # Separate the IDs to join back later.  
  customer_ids <- select(loans, loan_id = id, customer_id)
  
  set.seed(42)
  payments_0 <- loans %>% 
    select(loan_id = id, start_date, payment_amount, installments, 
        payment_coef) %>% 
    pmap_dfr(.f = .one_loan_payments) %>% 
    filter(due_date <= cut_date)
  
  payments_df <- payments_0 %>%   
    arrange(due_date, loan_id) %>% 
    mutate(id        = row_number(), 
        on_principal = as.numeric(NA), 
        on_interest  = as.numeric(NA), 
        on_penalty   = as.numeric(NA), 
        update_dt    = now()) %>% 
    left_join(customer_ids, by=c("loan_id")) %>% 
    select(8, 1, 13, 2:7, 9:12)
  
  return (payments_df)
}
  

csv_feather <- function (dataframe, path) {
  write_csv(    dataframe, glue("{path}.csv"    ))
  write_feather(dataframe, glue("{path}.feather"))
}
  
  