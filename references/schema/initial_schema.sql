


CREATE TABLE customers(
  id SERIAL,
  name CHAR,
  surname CHAR,
  birthdate DATE, 
  main_address CHAR,
  phone_number CHAR, 
  -- update_dt DATETIME, 

  PRIMARY KEY(id), 
  FOREIGN KEY(main_address) REFERENCES addresses(id)
);


CREATE TABLE addresses(
  id SERIAL, 
  customer_id CHAR, 
  street CHAR, 
  street_number INT,
  neighborhood CHAR,
  zipcode CHAR, 
  city CHAR, 
  -- interior_number CHAR,
  -- address_type CHAR,
  -- state CHAR,
  -- update_dt DATETIME, 

  PRIMARY KEY(id), 
  FOREIGN KEY(customer_id) REFERENCES customers(id)
);


CREATE TABLE loans(
  id SERIAL, 
  customer_id INT, 
  -- status CHAR,
  loan_product CHAR, 
  start_date DATE, 
  end_date DATE,  
  initial_amount FLOAT, 
  payment_amount FLOAT,
  -- remaining_amount FLOAT,
  -- update_dt DATETIME,

  PRIMARY KEY(id), 
  FOREIGN KEY(customer_id) REFERENCES customers(id), 
  FOREIGN KEY(loan_product) REFERENCES loan_products(id)
);


CREATE TABLE loan_products(
  id SERIAL, 
  frequency FLOAT, 
  -- interest_rate FLOAT, 
  -- update_type CHAR, 
  -- update_dt DATETIME,

  PRIMARY KEY(id)
);


CREATE TABLE payments(
  id SERIAL, 
  loan_id CHAR, 
  customer_id CHAR, 
  -- status CHAR
  due_amount FLOAT, 
  due_date DATE, 
  applied_amount FLOAT, 
  applied_date DATE, 
  update_dt DATE,

  PRIMARY KEY(id), 
  FOREIGN KEY(loan_id) REFERENCES loans(id),
  FOREIGN KEY(customer_id) REFERENCES customers(id)
);


