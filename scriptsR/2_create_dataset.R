# Diego Villamil
# CDMX, September 20th, 2020

source("../src/data/create_transform.R")
source("../src/visualization/db_helpers.R")

# Download the data -------------------------------------------------------

raw_dirs <- c("loans" = "../data/raw/loans_kaggle", 
          "customers" = "../data/raw/customers_briandunning")

download_loans_customers(raw_dirs)


# Data Transformation and Simulation ---------------------------------------------

loans_begin <- today() - months(15)
loans_end   <- today()

both_of_them  <- get_customers_and_addresses(250, age_ref=today())
customers_mod <- both_of_them[["customers"]] %>% 
  select(id, payment_coef)

loans_and_products <- get_loans(500, 250, within=c(loans_begin, loans_end))
loans_with_coef    <- loans_and_products[["loans"]] %>% 
  left_join(customers_mod, by=c("customer_id" = "id"))
  
payments <- simulate_payments(loans_with_coef, loans_end)


# Save and upload tables --------------------------------------------------

at_dir <- "../data/processed/schema"

csv_feather(both_of_them[["customers"]],   file.path(at_dir, "customers"))
csv_feather(both_of_them[["addresses"]],   file.path(at_dir, "addresses"))
csv_feather(loans_and_products[["loans"]], file.path(at_dir, "loans"))
csv_feather(loans_and_products[["loan_products"]], 
              file.path(at_dir, "loan_products"))
csv_feather(payments, file.path(at_dir, "payments"))


conn <- connect_postgres()
  
dbWriteTable(conn, "customers", both_of_them[["customers"]], append=TRUE)
dbWriteTable(conn, "addresses", both_of_them[["addresses"]], append=TRUE)
dbWriteTable(conn, "loans",    loans_and_products[["loans"]], append=TRUE)
dbWriteTable(conn, "payments", 
    loans_and_products[["loan_products"]], append=TRUE)
dbWriteTable(conn, "payments", payments, append=TRUE)

