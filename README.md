# AACT

Database for Aggregated Analysis of ClinicalTrials.gov  
<br>
<br>

***

<br>

## Purpose

This is a ruby on rails application that retreives the content of <a href="clinicaltrials.gov" target="_blank">clinicaltrials.gov</a> (via their API) and makes the information available in a relational database.  We do this to make this valuable body of information accessible to the public as a complete aggregated set of data.

If you need a copy of the database, but don't want to bother installing & running this app, copies of the database are available for download from the <a href='https://aact.ctti-clinicaltrials.org/snapshots' target='_blank'>AACT website (Download page).</a> We use pg_dump to create a snapshot of the database after each nightly update, so a version is always available with the most current info from clinicaltrials.gov.  
<br>
<br>

*** 

<br>

## Getting Started

1.  Install PostgreSQL 13.
    Here are some links that could help you setup  
    https://www.postgresql.org/download/linux/ubuntu/  
    https://www.postgresql.org/download/macosx/  
    Note: do not delete the template databases, meaning template0 and template1. They are what PostgreSQL uses to create all other databases. If you remove them you will no longer be able to make new databases.  

2.  Now we will focus on the “.pgpass” file for storing your connection info. Here is a document about the “.pgpass” file  
    https://www.postgresql.org/docs/current/libpq-pgpass.html  
    The “.pgpass” should be at your root. You can edit it using Vim or your preferred editor that lets you edit from the terminal. I will explain editing it using Vim commands.  
    `vim ~/.pgpass` this directs vim to open the file you want to edit. It will create that file if it does not already exist.  
    `i` this triggers insert mode (it will say insert at the bottom) so you can edit the file.  
    Add “hostname:port:database:username:password” to the file but fill in the words with your info.  
    Example: `localhost:5432:*:postgres:pg_password`  
    Press the `esc` button to leave insert mode.  
    `:xa` will save and close the file.  
    Now check that you can login to psql without giving a password  
    `psql -U postgres -d template1`  
    Look here for more Vim commands https://www.linux.com/training-tutorials/vim-101-beginners-guide-vim/  

3.  Now we will create the roles you need for running AACT.  
    `psql -U postgres -d template1` this allows you to enter the template1 database that comes with PostgreSQL.  
    `template1=# create role <your_aact_superuser> login password '<your_superuser_password>’;`  
    `template1=# alter user <your_aact_superuser> with superuser;`  
    `template1=# create role read_only;`  
    `template1=# \q` this exits out of psql  
    Verify your new user can login to psql with command: `psql -U <your_aact_superuser> -d template1`  
    You can exit the shell once you see you can log in.  

4.  Now we want to store the environmental variables for the superuser that you created in the previous step. That is the user you will be using within AACT to make database changes.  
    `vim ~/.bash_profile` You can switch out bash_profile for your usual file for storing environmental variables, such as an zshrc file.  
    `i` Enter insert mode and add the following to the file  
    `export AACT_DB_SUPER_USERNAME=<your_aact_superuser>`  
    `export AACT_PASSWORD=<your_superuser_password>`  
    `export AACT_PUBLIC_BETA_DATABASE_NAME=aact`  
    `export AACT_BETA_DATABASE_NAME=aact`  
    <br>
    By default, AACT saves files it creates in a directory under /aact-files. (Note, this is in the server root directory, not the root of the AACT application.)  To override this, use the AACT_STATIC_FILE_DIR environment variable to define a different directory.  Otherwise, you will need to create /aact-files at the server root directory and change permissions on it so that the rails application owner has permission to read/write to that directory.  
    `export AACT_STATIC_FILE_DIR=public/static` *we are removing the need to add this variable*  
    <br>
    The pg gem (used by AACT) will need to know where to find your PostgreSQL installation. For Mac you can direct it to that location by adding  
    `export PATH=$PATH:/Library/PostgreSQL/x.y/bin` *change x.y to the version number of your PostgreSQL installation, like: `export PATH=$PATH:/Library/PostgreSQL/13/bin`*  
    https://wikimatze.de/installing-postgresql-gem-under-ubuntu-and-mac/  
    <br>
    Press the `esc` button to leave insert mode, then `:xa` to save and close the file.  
    <br>
    `source ~/.bash_profile` refreshes/establishes the terminals connection to the file so it will pick up the variables you added.  
    *Note: you will need to use the source command whenever you edit the “.bash_profile” or open a new terminal.*  
    <br>
    You can add `your_aact_superuser` to the “.pgpass” file to save yourself having to type the password when logging into the shell. Add `hostname:port:database:<superuser_name>:<superuser_password>` to your pgpass file. If you aren’t sure how to do it follow the guidance in step 2.  

5.  Clone this repo: `git clone git@github.com:ctti-clinicaltrials/aact.git`  
    Note: Cloning with a ssh url requires that your local ssh key is saved to Github. The key verifies your permission to push and pull so you won't have to log in. If you haven't saved your ssh key to Github use the html url instead when cloning.  

6.  `cd aact` to enter the directory  

7.  Install a ruby version manager like rbenv, then install Ruby 2.6.2  

8.  Bundle install  

9.  You'll need to add a file called "connections.yml" to your config folder if it doesn't already exist. Inside of it paste the following code:  
    public:  
      encoding: utf8  
      adapter: postgresql  
      host: 159.203.80.25  
      port: 5432  
      database: aact  
      username:  
      password:  
    staging:  
      encoding: utf8  
      adapter: postgresql  
      host: 159.203.80.25  
      port: 5432  
      database: aact_alt  
      username:  
      password:  
    This file is mainly for running a docker container but it's called on by the Util::DbManager model when it initializes so you will get an error if it's not there when the model is called. That model manages database changes.  

10. Create databases and run migrations  
    `bin/rake db:create`  
    `bin/rake db:create RAILS_ENV=test`  
    `bin/rake db:migrate`  
    `bin/rake db:migrate RAILS_ENV=test`  
    `bin/rake db:copy_schema` this copies the structure (tables, columns and rows) of the ctgov schema over to the ctgov_beta schema.  
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

<br>
<br>
***

<br>

## Database explanation

Below you'll find an image that illustrates the different AACT databases and schemas, while briefly describes their purposes.
![Visualization of the database arrangment for AACT(backend) and AACT-Admin(frontend)](public/aact_architecture.png "AACT Database Visualization")   
<br>
<br>
***

<br>

## Populating the Database

The seed files are out of date so **DO NOT** call `db:seed`. Instead use the custom rake tasks.
These are your options: 
* `bin/rake db:restore_from_file[<path_to_file>,<database_name>]` *this method is currently not working*   
  For this option go to https://aact.ctti-clinicaltrials.org/snapshots and download a copy of the database. Give this task the path to the file you downloaded and it will upzip it before using it to populate the database.  
* `bin/rake db:restore_from_url[<url>,<database_name>]`  
  For this option go to https://aact.ctti-clinicaltrials.org/snapshots and copy the link for one of the database copies. Give this task the url you copied and it will download the file, upzip it, and use it to populate the database.  
    *Note: the following rake tasks take a very long time to run*  
* `bin/rake db:load[<days_back>,<event_type>,<full_featured>]`  
  The days back is an integer, the event_type only takes "full" or "incremental", full_featured is a boolean. You do not have to give it any parameters. If you have no studies it will populate your database with all the studies.  
* `bin/rake db:beta_load[<days_back>,<event_type>,<full_featured>]`  
  this works like the regular load but adds the data to `ctgov_beta` schema instead of the `ctgov` schema.  
* `bin/rake db:both_load[<days_back>,<event_type>,<full_featured>]`  
  this populates the `ctgov` schema and then the `ctgov_beta` schema  
<br>
<br>

***

<br>

## Where the data comes from

AACT downloads the complete set of studies from ClinicalTrials.gov as a zipfile that contains an xml file for each study [[https://clinicaltrials.gov/search/resultsxml=true]].  Until recently, the ClinicalTrials.gov API only provided this info in XML format.  In June, 2019, an improved API was deployed in beta which provides a far more flexible way to retrieve studies from ClinicalTrials.gov and also lets you retrieve it as json.  [[https://clinicaltrials.gov/ct2/about-site/new]]
<br>
<br>