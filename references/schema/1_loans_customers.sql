-- Diego Villamil
-- CDMX, September 19, 2020


CREATE TABLE customers(
  id              SERIAL,
  name            CHAR,
  surname         CHAR,
  birthdate       DATE, 
  main_address    INT,
  phone_number    CHAR,
  payment_coef    FLOAT,
  update_dt       TIMESTAMP, 

  PRIMARY KEY(id)
  --FOREIGN KEY(main_address) REFERENCES addresses(id)
);


CREATE TABLE addresses(
  id              SERIAL, 
  customer_id     INT,  
  street          CHAR, 
  street_number   CHAR,
  interior        CHAR,
  neighborhood    CHAR,
  state           CHAR,
  zipcode         CHAR, 
  city            CHAR, 
  address_type    CHAR,
  update_dt       TIMESTAMP, 

  PRIMARY KEY(id)
  --FOREIGN KEY(customer_id) REFERENCES customers(id)
);


CREATE TABLE loans(
  id              SERIAL, 
  customer_id     INT, 
  loan_product    CHAR, 
  start_date      DATE, 
  end_date        DATE,  
  principal       FLOAT, 
  payment_amount  FLOAT,
  installments    INT,
  status          CHAR,
  balance         FLOAT,
  update_dt       TIMESTAMP,

  PRIMARY KEY(id)
  --FOREIGN KEY(customer_id) REFERENCES customers(id), 
  --FOREIGN KEY(loan_product) REFERENCES loan_products(id)
);


CREATE TABLE loan_products(
  id              SERIAL, 
  frequency       FLOAT, 
  interest_rate   FLOAT,    
  penalty_rate    FLOAT,    
  penalty_type    CHAR,
  update_dt       TIMESTAMP,

  PRIMARY KEY(id)
);


CREATE TABLE payments(
  id              SERIAL, 
  loan_id         INT, 
  customer_id     INT, 
  due_amount      FLOAT, 
  due_date        DATE, 
  applied_amount  FLOAT, 
  applied_date    DATE, 
  installment     INT,
  status          CHAR,    
  on_principal    FLOAT,
  on_interest     FLOAT,
  on_penalty      FLOAT,
  update_dt       DATE,

  PRIMARY KEY(id)
  --FOREIGN KEY(loan_id) REFERENCES loans(id),
  --FOREIGN KEY(customer_id) REFERENCES customers(id)
);


