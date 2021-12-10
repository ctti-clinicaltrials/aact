# AACT

### What it is:  
Database for Aggregated Analysis of ClinicalTrials.gov  

<br>

### Purpose:  
This is a ruby on rails application that retreives the content of <a href="clinicaltrials.gov" target="_blank">clinicaltrials.gov</a> (via their API) and makes the information available in a relational database.  We do this to make this valuable body of information accessible to the public as a complete aggregated set of data.

If you need a copy of the database, but don't want to bother installing & running this app, copies of the database are available for download from the <a href='https://aact.ctti-clinicaltrials.org/snapshots' target='_blank'>AACT website (Download page).</a> We use pg_dump to create a snapshot of the database after each nightly update, so a version is always available with the most current info from clinicaltrials.gov.  

<br>

### Database explanation:  

Below you'll find an image that illustrates the different AACT databases and schemas, while briefly describing their purposes.
![Visualization of the database arrangment for AACT(backend) and AACT-Admin(frontend)](public/aact_architecture.png "AACT Database Visualization")   

<br>

### Data Source:  

AACT downloads the complete set of studies from ClinicalTrials.gov as a zipfile that contains an xml file for each study https://clinicaltrials.gov/search/resultsxml=true.  Until recently, the ClinicalTrials.gov API only provided this info in XML format.  

In June, 2019, an improved API was deployed in beta which provides a far more flexible way to retrieve studies from ClinicalTrials.gov and also lets you retrieve it as json. We have setup AACT to also retrieve data from the beta API.

You can find information about the ClinicalTrials.gov beta API here: https://clinicaltrials.gov/api/gui



<br>
<br>

***

<br>

## Getting Started

1.  Install PostgreSQL 13. If you have a Mac you can use brew to install PostgreSQL.  
    `brew install postgresql`  

    Here are some links that could help you setup  
    https://www.postgresql.org/download/linux/ubuntu/  
    https://www.postgresql.org/download/macosx/  
    Note: do not delete the template databases, meaning template0 and template1. They are what PostgreSQL uses to create all other databases. If you remove them you will no longer be able to make new databases.  

2.  Now we will create the roles you need for running AACT.  
    `psql postgres` this allows you to enter the postgres database that comes with PostgreSQL.  
    `postgres=# create role <your_aact_superuser> login password '<your_superuser_password>’;`  
    `postgres=# alter user <your_aact_superuser> with superuser;`  
    `postgres=# create role read_only;`  
    `postgres=# create database aact_alt;`  
    `postgres=# \q` this exits out of psql  
    Verify your new user can login to psql with command: `psql -U <your_aact_superuser> -d postgres`  
    You can exit the shell once you see you can log in.

3.  If your terminal asks for a password when logging in to psql you can give it the password automatically by adding it to the “.pgpass” file. If you haven’t been asked for a password, you can skip this step.
    The “.pgpass” should be at your root.  
    `echo 'localhost:5432:aact:<superuser_name>:<superuser_password>'  >> ~/.pgpass`  
    Now check that you can login to psql without giving a password  
    `psql -U aact_pg_user -d postgres`
    You can exit the shell once you see you can log in without a password.

    Here is a document about the “.pgpass” file https://www.postgresql.org/docs/current/libpq-pgpass.html.   

4.  Now we want to store the environmental variables for the superuser that you created in the previous step.     That is the user you will be using within AACT to make database changes. You can store these wherever is appropriate for your system. On a Mac you can store it in your “.zshrc”. On all systems you can also store it in your “.bash_profile” or “.bashrc”.  
    For the following commands I’m storing variables in the “.zshrc” file, change out that file in the commands for the one you use for storing variables.  
    `echo 'export AACT_DB_SUPER_USERNAME=<your_aact_superuser>' >> ~/.zshrc`  
    `echo 'export AACT_PASSWORD=<your_superuser_password>'  >> ~/.zshrc`   
    `echo 'export AACT_PUBLIC_DATABASE_NAME=aact'  >> ~/.zshrc`  
    `echo 'export AACT_ALT_PUBLIC_DATABASE_NAME=aact_alt'  >> ~/.zshrc`  
    `echo 'export PUBLIC_DB_USER=<your_aact_superuser>'  >> ~/.zshrc`  
    `echo 'export PUBLIC_DB_PASS=<your_superuser_password>'  >> ~/.zshrc`    
  
    `source ~/.zshrc` to load the variables into the terminal session.  
    
    Depending on where you store the variables you may need to call `source` on that file each time you open a new terminal. This is not necessary for “.zshrc”.   

5.  Clone this repo: `git clone git@github.com:ctti-clinicaltrials/aact.git`  
    Note: Cloning with a ssh url requires that your local ssh key is saved to Github. The key verifies your permission to push and pull so you won't have to log in. If you haven't saved your ssh key to Github use the html url instead when cloning.  

6.  `cd aact` to enter the directory  

7.  Install a ruby version manager like rbenv, then install Ruby 2.6.2  

8.  Bundle install  
    The pg gem (used by AACT) may have trouble finding your PostgreSQL installation. If not, skip this step.  
    For Mac you can direct it to the right location location by adding  
    `echo ‘export PATH=$PATH:/Library/PostgreSQL/x.y/bin’  >> ~/.zshrc` change x.y to the version number of your PostgreSQL installation.  
    Example: `export PATH=$PATH:/Library/PostgreSQL/13/bin`  
    https://wikimatze.de/installing-postgresql-gem-under-ubuntu-and-mac/  

9.  Use the "connections.yml.example" file and copy it to the file "connnections.yml" and just update what needs to be updated for the local environment.
    In the terminal, type `cp connections.yml.example connections.yml`.
    The file called "connections.yml" is mainly for running a docker container but it's called on by the Util::DbManager model when it initializes so you will get an error if it's not there when the model is called. That model manages database changes.  

10. Create databases and run migrations  
    `bin/rake db:create`  
    `bin/rake db:create RAILS_ENV=test`  
    `bin/rake db:migrate`  
    `bin/rake db:migrate RAILS_ENV=test`  

11. Grant read_only privileges  
    `bin/rake grant:db_privs:run`  
    `bin/rake grant:db_privs:run RAILS_ENV=test`  

<br>
<br>

***

<br>

## Populating the Database

The seed files are out of date so **DO NOT** call `db:seed`. Instead use the custom rake tasks.
These are your options: 
* `bin/rake db:restore_from_file[<path_to_file>,<database_name>]`   
  For this option go to https://aact.ctti-clinicaltrials.org/snapshots and download a copy of the database. Unzip the snapshot folder.  
  The file path will likely look like: `~/Downloads/<unzipped_snapshot_folder>/postgres_data.dmp`  
  Example: `~/Downloads/20210906_clinical_trials/postgres_data.dmp`.  
  Give this task the path to the postgres_data.dmp file and it will use it to populate the database.  
  Example: `bin/rake "db:restore_from_file[~/Downloads/20210906_clinical_trials/postgres_data.dmp,aact]"`  
* `bin/rake db:restore_from_url[<url>,<database_name>]`  
  For this option go to https://aact.ctti-clinicaltrials.org/snapshots and copy the link for one of the database copies. Give this task the url you copied and it will download the file, unzip it, and use it to populate the database.  
    *Note: the rake tasks below take a very long time to run. You should not set full_featured to true if working locally.*  
* `bin/rake db:load[<days_back>,<event_type>,<full_featured>]`  
  The days back is an integer, the event_type only takes "full" or "incremental", full_featured is a boolean. You do not have to give it any parameters. If you have no studies it will populate your database with all the studies.  

<br>
<br>

***

<br>

## Workflow
### Branches:
- master - This is the stable production branch, anything merged to master is meant to be propagated to production. Hot fixes will be merged directly to master, then pulled into dev. All other Pull Requests (PRs) will be merged into dev first.  
- dev - This branch contains the changes for the sprint. It is an accumulation of everything that we believe is working and ready for the next release.  
- feat/AACT-NUM-description - "AACT-Num" refers to the number of the card on Jira. Description is the name of the feature. This is the naming conventions for a feature that you are working on that eventually will be merged to dev once the PR is approved.  
- fix/AACT-NUM-description - This is the naming conventions for a bug fix. The PR will be merged into dev when approved.  
- hotfix/AACT-220-description - This is the naming conventions for an emergency fix. This branches off of master and gets merged into master when the PR is approved because it is a fix that needs to be deployed ASAP.  

Treat dev as the main branch. Only branch off of master if you need to do a hotfix.

### Normal Process
1.  Pick a ticket to work on  
2.  Branch off of dev using the naming convention mentioned above to name your branch  
3.  Work on the feature or bug fix  
4.  Run tests and make sure they pass before creating a PR  
5.  Once complete create a PR to dev  
6.  Request review for the PR from two people  
7.  If there are change requests, makes the changes, run tests and request a review. If not continue to the next step.   
8.  The PR will be approved and merged to dev  
9.  At the end of the sprint the dev will be merged to master (we will add a semantic tag, this is where we will decide which version number to pick)  
10.  Deploy master to production  

### Hotfix Process
1.  Branch off of master using the naming convention mentioned above to name your branch   
2.  Work on the bug fix  
3.  Run tests and make sure they pass
4.  Create PR to master  
5.  Request review for the PR from two people. PR review could be expedited depending on the emergency  
6.  Merge PR to master  
7.  Deploy master to production  
8.  Bring changes into dev (once things stabilize)  
