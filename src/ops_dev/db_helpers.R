# Diego Villamil
# CDMX, September 18th, 2020


get_active_loans <- function (conn, type="date") {

  tbl_ref <- switch (type
  , "date"    = tbl(conn, "loans") %>% 
          filter(betweens(today(), start_date, end_date))
  , "default" = tbl(conn, "loans") %>% 
          filter(remaining_amount > 0, not(is_default)) )

  return (tbl_ref)
}


collect_customers <- function (query, columns) {
  if (missing(columns)) columns <- c("name", "surname", "phone_number")

  customers_df <- query %>%
    select(one_of(columnas)) %>%
    collect()

  return (customers_df)
}
