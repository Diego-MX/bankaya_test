# Diego Villamil
# CDMX, September 21st, 2020


import sys
import os
import pandas as pd
from datetime import date
from dotenv import load_dotenv

load_dotenv("../.env")
sys.path.append(os.getenv("REPO_DIR"))
from src.visualization import reports

#%%
conn = reports.connect_postgres()

a_multiple_loans = reports.multiple_active_loans(conn, active_type="date")
b_consecutive    = reports.consecutive_payments(conn, "full_ontime", "date")
c_one_active_loan = reports.one_active_loan(conn, True, "date")
d_zipcode_and_age = reports.zipcode_and_age(conn, [18, 25, 40, 60, 80])

conn.disconnect()


#%% 

date_lab = date.today().strftime("%y%m%d")

a_multiple_loans.to_feather(f"{date_lab}_a_active_loans.feather")
b_consecutive.to_feather(   f"{date_lab}_b_consecutive_payments.feather")
c_one_active_loan.to_feather(f"{date_lab}_c_one_active_loan.feather")
d_zipcode_and_age.to_feather(f"{date_lab}_d_zipcode_and_ages.feather")

a_multiple_loans.to_csv(f"{date_lab}_a_active_loans.csv")
b_consecutive.to_csv(   f"{date_lab}_b_consecutive_payments.csv")
c_one_active_loan.to_csv(f"{date_lab}_c_one_active_loan.csv")
d_zipcode_and_age.to_csv(f"{date_lab}_d_zipcode_and_ages.csv")

