Data Scientist/Arquitect Bankaya Test
by Diego Villamil

# Loand and Payment Schema

This repository contains code for starting a test database regarding loan and 
payment data.  In addition, a few reports are included to be run easily 
as to follow customer behavior.  

The folder structure is based on Cookiecutter template for data science with 
Python ([link here]), with a few modifications in order to accommodate R scripting. 
Being R a more comfortable language for scripting logic (humble opinion), I 
developed the queries first in R, and later ported them over to Python, as requested. 

## Answers first


The challenges questions can be seen in [this document].  So we follow those 
questions as we describe this project's structure. 

1. Database diagram and schema.  
  These two are stored in `./references/schema/1_loans_customers`, with extensions
  `.pdf` and `.sql` respectively.  
  
  As for the diagram tables, their colors represent the type of activity that 
  each should expect: 
  + Loan products, changes very rarely, and therefore are kept cold. 
  + Customers, addresses, and loans are the core of business, they might be often
    updated but not as much as the minutely operation of payments. 
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
  charateristics on how to compute new payments on the loans.  The penalty type 
  may be one of _next\_payment_ or _all\_payments_, for still simplified products. 

  The rest of the extra columns are indicated in the diagrams with underscore, 
  and the schema query as comments.  We describe those changes: 
  
  + The addresses' characteristics include most of the popular fields, and also 
  an `address_type` for what was mentioned earlier to allow address changes, 
  or possible use of them.
  
  + The loans total amount was labeled `principal`, and included new columns 
  for (current) `balance` and loan `status` (active, completed, default, etc.)
  The number of installments is also helpful for many computations. 
  
  + The payments table also include `status` for keeping track of its activity, 
  and `on_principal`, `on_interest`, `on_penalty` as breakdown to how the payments
  are recorded into the books. Possible statuses are: _complete_, _partial_, _missed_.  

  + All tables include an `_update_dt` datetime to keep track of changes. 
  

2.  






Project Organization
------------

    ├── LICENSE
    ├── Makefile           <- Makefile with commands like `make data` or `make train`
    ├── README.md          <- The top-level README for developers using this project.
    ├── data
    │   ├── external       <- Data from third party sources.
    │   ├── interim        <- Intermediate data that has been transformed.
    │   ├── processed      <- The final, canonical data sets for modeling.
    │   └── raw            <- The original, immutable data dump.
    │
    ├── docs               <- A default Sphinx project; see sphinx-doc.org for details
    │
    ├── models             <- Trained and serialized models, model predictions, or model summaries
    │
    ├── notebooks          <- Jupyter notebooks. Naming convention is a number (for ordering),
    │                         the creator's initials, and a short `-` delimited description, e.g.
    │                         `1.0-jqp-initial-data-exploration`.
    │
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    │
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures to be used in reporting
    │
    ├── requirements.txt   <- The requirements file for reproducing the analysis environment, e.g.
    │                         generated with `pip freeze > requirements.txt`
    │
    ├── setup.py           <- makes project pip installable (pip install -e .) so src can be imported
    ├── src                <- Source code for use in this project.
    │   ├── __init__.py    <- Makes src a Python module
    │   │
    │   ├── data           <- Scripts to download or generate data
    │   │   └── make_dataset.py
    │   │
    │   ├── features       <- Scripts to turn raw data into features for modeling
    │   │   └── build_features.py
    │   │
    │   ├── models         <- Scripts to train models and then use trained models to make
    │   │   │                 predictions
    │   │   ├── predict_model.py
    │   │   └── train_model.py
    │   │
    │   └── visualization  <- Scripts to create exploratory and results oriented visualizations
    │       └── visualize.py
    │
    └── tox.ini            <- tox file with settings for running tox; see tox.readthedocs.io


--------

<p><small>Project based on the <a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter data science project template</a>. #cookiecutterdatascience</small></p>
