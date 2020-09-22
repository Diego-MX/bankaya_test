# Diego Villamil
# CDMX, September 21st, 2020

import os
from datetime import date
import pandas as pd
import psycopg2 as psql
import sqlalchemy as alq
from sqlalchemy import func, sql as sql
from dotenv import load_dotenv
load_dotenv("../.env")

def meta_connect_postgres():
# conn = psql.connect(
#     host=os.getenv("PSQL_HOST"), 
#     user=os.getenv("PSQL_USER"), 
#     password=os.getenv("PSQL_PASS"), 
#     database=os.getenv("PSQL_BASE"))
  url = "postgresql://{}:{}@{}:{}/{}".format(
    os.getenv("PSQL_HOST"), 
    os.getenv("PSQL_USER"), 
    os.getenv("PSQL_PASS"), 
    os.getenv("PSQL_BASE"))
 
  engine = alq.create_engine(url)
  conn = engine.connect()
  meta = alq.MetaData(bind=engine, reflect=True)
  
  meta_conn = {"connection": conn, "metadata": meta}
  return meta_conn 


def get_active_loans(meta_conn, type):
  loans_t = alq.Table("loans", meta_conn["meta"])

  if type == "date":
    date_obj = date.today()
    loans_s = loans_t.where(
          date_obj.between(loans_t.c.start_date, loans_t.c.end_date))
  else: 
    loans_s = NULL 
  return loans_s


def collect_customers(query, columns=None):
  columns = columns | ["name", "surname", "phone_number"]
  columns = [f"customers.c.{col}" for col in columns]

  customers_df = query.select(columns).execute()
  return customers_df
  

def multiple_active_loans(meta_conn, active_type):
  customers_t = alq.Table("customers", meta_conn["meta"])

  loans_t = get_active_loans(meta_conn, active_type)
  loans_u = loans_t.group_by(loans_t.c.customer_id).\
    having(func.count(loans_t.c.id) > 1)
  
  customers_u = customers_t.join(loans_u, 
        customers_t.c.id == loans_u.c.customer_id)
  customers_v = collect_customers(customers_u)
  return customers_v


def consecutive_payments(meta_conn, which_loans, active_type):
  loans_t = get_active_loans(meta_conn, active_type)  
  payments_t = alq.Table("payments", meta_conn["meta"])
  customers_t = alq.Table("customers", meta_conn["meta"])

  payments_u = alq.select([payments_t, 
      (payments_t.c.applied_date <= payments_t.c.due_date).label("on_time"), 
      (payments_t.c.applied_amount <= payments_t.c.due_amount).label("full_paid")]).\
    where(payments_t.c.loan_id.op("in")(alq.select([loans_t.c.id])))

  if   which_loans == "full_ontime": 
    get_it = (payments_u.c.on_time & payments_u.c.full_paid).label("get_it")
  elif which_loans == "full_paid":
    get_it = payments_u.c.full_paid
  elif which_loans == "ontime":
    get_it = payments_u.c.on_time.label("get_it")
  else:
    get_it = None
  
  payments_v = alq.select([payments_u, get_it.lag().over(
        group_by=payments_u.c.loan_id, order_by=payments_u.c.due_date).
      label("get_prev")])
  payments_w = payments_v.where(get_it & payments_v.get_prev)

  customers_u = alq.select([customers_t]).\
    where(customers_t.c.id.op("in")(alq.select([payments_w.c.customer_id])))
  customers_v = collect_customers(customers_u)
  return customers_v


def one_active_loan(meta_conn, also_prev_loans, active_type):
  payments_t = alq.Table("payments", meta_conn["meta"])
  
  loans_t = get_active_loans(meta_conn, active_type)
  loans_u = loans_t.group_by(loans_t.c.customer_id).\
    having(func.count(loans_t.c.id) == 1)

  if also_prev_loans:
    get_loans = payments_t.c.customer_id.op("in")(alq.select([loans_u.c.customer_id])) 
  else:
    get_loans = payments_t.c.loan_id.op("in")(alq.select([loans_u.c.id])) 
    
  payments_u = alq.select([payments_t.c.customer_id, 
      func.count(payments_t.c.payment_id).label("n_payments"), 
      func.sum(payments_t.c.applied_amount).label("amount")]).\
    where(get_loans).\
    group_by(payments_t.c.customer_id)

  payments_v = alq.select([
      func.avg(payments_u.c.n_payments).label("avg_payments"), 
      func.sum(payments_u.c.amount).label("total_amount")])

  return meta_conn["conn"].execute(payments_v)


def zipcode_and_age(meta_conn, buckets):
  pass