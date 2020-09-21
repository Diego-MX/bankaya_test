# Data Scientist-Arquitect Bankaya Test
### by Diego Villamil
### September, 2020


## Loan and Payment Exercises

This repository contains code for starting a test database regarding loan and 
payment data.  In addition, a few reports are included to be run easily 
as to follow customer behavior.  

The folder structure is based on Cookiecutter template for data science with 
Python ([link here][cookiecutter]), with a few modifications in order to accommodate R scripting. 
Being R a more comfortable language for scripting logic (humble opinion), I 
developed the queries first in R, and was aiming at porting them over to Python. 
However, due to time constraints this wasn't accomplished and therefore request
your consideration for evaluation in R.  

## Answers to the questions

The challenge questions can be seen in [this document].  So we follow those 
questions as we describe this project's structure. 

1. Database diagram and schema.  
  These two are stored in `./references/schema/1_loans_customers`, with extensions
  `.pdf` and `.sql` respectively.  

  As for the diagram tables, their colors represent the type of activity that 
  each should expect: 
  + Loan products, changes very rarely, and therefore their table is blue. 
  + Customers, addresses, and loans are the core of business, they might be often
    updated but not as much as the payments operations. 
  + Payments are orange given that it is the most active table.  I didn't use red
    as it is often associated with caution.  We'll leave that caution for another
    session. 

  I have also created two additional tables, and several columns in most of the tables
  in order to facilitate some of the queries, and with an aim (conservative) towards
  further product development. 

  + Addresses Table.  It captures the customers' addresses' data.  It allows 
  changing addresses, and keeping track of the old ones.   And it also opens the
  possibility to use different types of addresses, e.g. residence and billing. 

  + Loan Products Table.  This keeps a separate track of the products that are 
  offered to the customers.  The loans' `frequency`'s are brought over to this table, 
  and I also included `interest_rate`, `penalty_rate`, `penalty_type` as 
  charateristics on how to compute new payments on the loans.  While these aren't
  used in our challenge, I wanted to include them as to complete the loan products. 
  The penalty type may be one of _next\_payment_ or _all\_payments_, for still 
  simplified products. 

  The rest of the extra columns are indicated in the diagrams with underscore, 
  and the schema query as comments.  We describe those changes: 

  + The customers attributes are the ones suggested, with an additional one of
  `payment_coef` that in real world may suggest a credit score, but was come up
  for this exercise as to generate their payments.  

  + The addresses' characteristics include most of the popular fields, and also 
  an `address_type` for what was mentioned earlier to allow address changes, 
  or possible use of them.
  
  + The loans total amount was labeled `principal`, and included new columns 
  for (current) `balance` and loan `status` (active, completed, default, etc.)
  The number of installments is also helpful for many computations. 
  
  + The payments table also include `status` for keeping track of its activity, 
  and `on_principal`, `on_interest`, `on_penalty` as breakdown to how the payments
  are recorded into the books. Possible statuses are: _complete_, _partial_, 
  _missed_, _late_. 

  + All tables include an `_update_dt` datetime to keep track of changes.  Its  
  purpose is to indicate simple database design practices, although not used in our exercise. 
  

2. Getting sample data used to populate the database, was the most challenging 
  part.  After configuration of a GCP-hosted postgres database, the steps to 
  populate it, are the following.  
  
  + Getting and creating data
    The script in `scriptsR/2_create_dataset.R` follows the following steps.
    The individual functions are stored in `src/data/create_transform.R`. 

    Upon exploring a few webdsites with loan sample data, the best one to use is 
    one dataset from Kaggle, with several modifications.  From here, I kept the 
    principal amount and the number of installments for each loan.  The starting
    dates were randomized, as well as the interest rate (which I added), taken 
    from the product loans. 

    As for the customer data, I used another dataset in the website (www.briandunning.com)[briandunning]
    with almost complete information.  The extra information is the `birthdate`
    and also the `payment_coef` used to simulate payments. 
    
    The payments were simulated for each loan in their calendarized schedules. 

  + Saving and writing
    The generated tables are written locally as both `feather` and `csv` files. 
    And then uploaded to a newly created Postgres database hosted in GCP. 

3. As mentioned earlier, these scripts are written in R.  
    In order to run them, the script `scriptsR/3_query_reports.R` is run. 
    This creates the tables and writes the results to `reports/...`. 
    To follow the logic details, the source file `src/visualization/query_reports.R`
    is used. 

    Some of the comments on the calculations are: 
    + We use a connection to postgres, whose parameters are read from `.env`.  
    + Getting active loans is a separate process on itself, so I coded it separately
      based on a criteria parameter.  For the purpose I used _date_ criteria, 
      but others may be implemented as well. 
    + Collecting customers is also used several times, and checks on the column names. 
    + For report (b) on getting customers with consecutive payments, a criteria
      parameter is used.  Since the simulations were carried out in a relatively 
      simple fashion, there's little chnage when using the criteria.  
      But still, leaves the option to open to create new ways to classify such payments. 
    + For section (c) on getting customers with one active loan, the option to 
      get `also_previous_loans` handles the literary condition of all paymentes 
      from that customer.  Turn it off, to use only the payments of that loan. 
    + For section (d), I had initially considered a free parameter for the age 
      buckets, however technical difficulties forced to only have 5 buckets. 

# Considerations

Given a unique compromise of delivering code in R, instead of Python.  I include 
some preparation code to have it run in a local machine.  

1. Install Postgres client.
2. Install R and Rstudio. 
3. Install packages from `reqs_R.txt`.  
4. Open RStudio project file `scriptsR/scriptsR.Rproj`. 
5. Modify environment file `.env` with credentials.


# Final conclusions

Working on this task was both fun and slightly rushing.  The only compromise in 
the end is the code being in R, and not Python, but with the satisfaction that it be
run completely from end to end.  That is to say, the creation of a sample data, 
with its corresponding simulations, and having ported over to Postgres came out 
very well. 

Smaller considerations were put into creating a more product-oriented database or 
having the necessary elements to solve the exercises.  That is to say, even though
a fully functional production schema would be out of the scope of this test, I decided
to add a few elements to make it look like so.  For example, separating address and
customer, or loan product from the loan itself.  

On the scripting procedures I was also able to structure the code to a usable status. 
With help from the folder skeleton that already separates the project files, there
is consistency in having both scripts to do what we want, and how we decided to do it. 
For example `2_create_dataset.R` creates the dataset with functions at a macro level, 
but calls `src/data/create_and_transform.R` where all the pertinent functions are
defined. 

Please let me know any questions are related to this project.  I thank you for the 
opportunity to work on this challenge.  And I hope to continue with the conversation. 

Best regards. 







[cookiecutter]: "https://drivendata.github.io/cookiecutter-data-science/"
[briandunning]: "https://www.briandunning.com/sample-data/us-500.zip"
