# Diego Villamil
# CDMX, September 18th, 2020 

library(RPostgres)
filter <- dplyr::filter


connect_postgres <- function () {
  conn <- dbConnect(Postgres(),
    dbname   = Sys.getenv("PSQL_BASE"),
    host     = Sys.getenv("PSQL_HOST"),
    user     = Sys.getenv("PSQL_USER"),
    password = Sys.getenv("PSQL_PASS"))
  return (conn)
}


get_active_loans <- function (conn, type="date") {
  
  tbl_ref <- switch (type
  , "date"    = tbl(conn, "loans") %>% 
   filter(between(today(), start_date, end_date))
  , "default" = tbl(conn, "loans") %>% 
   filter(remaining_amount > 0, not(is_default)) )

  return (tbl_ref)
}


collect_customers <- function (query, columns) {
  if (missing(columns)) columns <- c("name", "surname", "phone_number")
  
  customers_df <- query %>%
    select(one_of(columns)) %>%
    collect()
  
  return (customers_df)
}


multiple_active_loans <- function (conn,
      active_type="date") {

  multiple_loans <- get_active_loans(conn, active_type) %>%
    group_by(customer_id) %>%
    summarize(n_loans = n()) %>%
    filter(n_loans > 1) 

  the_customers_df <- tbl(conn, "customers") %>%
    right_join(multiple_loans, by=c("id" = "customer_id")) %>%
    collect_customers()

  return (the_customers_df)
}


consecutive_payments <- function (conn,
      which_loans="full_ontime", active_type="date") {

  active_loans <- get_active_loans(conn, active_type)

  which_to_get <- switch (which_loans
  , "full_ontime" = quos(get_it = on_time & full_paid)
  , "full_paid"   = quos(get_it = full_paid)
  , "ontime"      = quos(get_it = on_time)
  )

  payment_preparation <- tbl(conn, "payments") %>%
    semi_join(active_loans, by=c("loan_id" = "id")) %>%
    group_by(loan_id) %>%
    arrange(due_date) %>%
    mutate(on_time = applied_date   <= due_date,
         full_paid = applied_amount >= due_amount,
         !!!which_to_get,
         consecutive = get_it & lead(get_it))

  payment_selection <- payment_preparation %>%
    group_by(customer_id, loan_id) %>%
    summarize(any_pymt = any(consecutive, na.rm=TRUE)) %>%
    group_by(customer_id) %>%
    summarize(any_pymt = any(any_pymt, na.rm=TRUE)) %>%
    filter(any_pymt)

  the_customers_df <- tbl(conn, "customers") %>%
    right_join(payment_selection, by=c("id" = "customer_id")) %>%
    collect_customers()

  return (the_customers_df)
}


one_active_loan <- function (conn,
      also_previous_loans=TRUE, active_type="date") {

  customers_one_loan <- get_active_loans(conn, active_type) %>%
    group_by(customer_id) %>%
    mutate(n_loans = n()) %>%
    filter(n() == 1)

  join_column <- if_else(also_previous_loans, "customer_id", "loan_id")

  payments_from_them <- tbl(conn, "payments") %>%
    semi_join(customers_one_loan, by=join_column) %>%
    group_by(customer_id) %>%
    summarize(n_payments = n(),
        amount = sum(applied_amount, na.rm=TRUE))

  the_totals <- payments_from_them %>%
    summarize(
        avg_payments = mean(n_payments, na.rm=TRUE),
        amount = sum(amount, na.rm=TRUE)) %>%
    collect()

  return (the_totals)
}


zipcode_and_age <- function (conn, buckets) {

  if (missing(buckets)) buckets <- c(18, 25, 40, 60, 80)
    bucket_labels <- buckets %>% head(-1) %>% sprintf("%d-...", .)

  if (min(buckets) < 18)
    warning("Sólo hay préstamos para adultos mayores de 18, pero
             se indicó un límite menor a 18.")
  if (min(buckets) > 18)
    warning("Se indicó un límite de edad mayor a 18 años,
             algunos clientes no se considerarán. ")

  if (length(buckets) != 5) {
    stop("Currently we only allow five age buckets.") 
  } else {
    for (i=1:4) assign("buckets_")
  }
    
  customer_labels <- tbl(conn, "customers") %>%
    left_join(tbl(conn, "addresses"), by=c("main_address" = "id")) %>%
    mutate(age = (today() - birthdate)/365.25,
      # age_grp= cut(age, buckets, bucket_labels, right=FALSE)
      age_grp  = case_when(
          age < buckets_2 ~ bucket_labels[1], 
          age < buckets_3 ~ bucket_labels[2], 
          age < buckets_4 ~ bucket_labels[3], 
          age < buckets_5 ~ bucket_labels[4], 
          TRUE ~ NA_character_)) %>% collect()

  the_grp_payments_df <- tbl(conn, "payments") %>%
    left_join(customer_labels, by=c("customer_id" = "id")) %>%
    group_by(age_grp, zipcode) %>%
    summarize(total_amount = sum(applied_amount, na.rm=TRUE)) %>%
    collect()

  return (the_grp_payments_df)
}

