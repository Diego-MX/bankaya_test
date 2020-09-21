# Diego Villamil
# CDMX, 18 de septiembre 2020

source("../src/visualization/query_reports.R")
# Sources the script to generate reports.  

conn <- connect_postgres()

a_active_loans <- multiple_active_loans(conn, active_type="date")

b_consecutive <- consecutive_payments(conn, "full_ontime", "date") 

c_one_active_loan <- one_active_loan(conn, TRUE, "date")

d_zipcode_and_age <- zipcode_and_age(conn, c(18, 25, 40, 60, 80)) 

dbDisconnect(conn)


write_csv(a_active_loans, "../reports/%s_a_active_loans.csv" %>% 
  sprintf(today() %>% format("%y%m%d")))

write_csv(b_consecutive, "../reports/%s_b_consecutive.csv" %>% 
  sprintf(today() %>% format("%y%m%d")))

write_csv(c_one_active_loan, "../reports/%s_c_one_active_loan.csv" %>% 
  sprintf(today() %>% format("%y%m%d")))

write_csv(d_zipcode_and_age, "../reports/%s_d_zipcode_and_age.csv" %>% 
  sprintf(today() %>% format("%y%m%d")))


