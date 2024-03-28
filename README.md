# AACT

AACT or Aggregated Analysis of ClinicalTrials.gov is an application for retrieving all of the public data from <a href="clinicaltrials.gov" target="_blank">clinicaltrials.gov</a> (via their API) and make the information available in a relational database.  We do this to make this valuable body of information accessible to the public as a complete aggregated set of data.

If you need a copy of the database, but don't want to bother installing & running this app, copies of the database are available for download from the <a href='https://aact.ctti-clinicaltrials.org/snapshots' target='_blank'>AACT website (Download page).</a> We use pg_dump to create a snapshot of the database after each nightly update, so a version is always available with the most current info from clinicaltrials.gov.  

### Database Explanation:  

Below you'll find an image that illustrates the different AACT databases and schemas, while briefly describing their purposes.
![Visualization of the database arrangment for AACT(backend) and AACT-Admin(frontend)](public/aact_architecture.png "AACT Database Visualization")   

## Requireqments

- Install zip  
    - For mac `brew install zip`
    - For windows `gem install rubyzip` 
    - For linux `sudo apt install ruby-zip`
- Install [graphviz](https://graphviz.org/download/)
- Install wget  
    - For mac `brew install wget`
    - For [windows](http://gnuwin32.sourceforge.net/packages/wget.htm)
    - For Ubuntu and Debian `sudo apt install wget`
    - For CentOS and Fedora `sudo yum install wget`

## Before Start

Common for Core and Admin apps setting up problems/issues:

1. Ubuntu versions 22.04 and newer have no built-in openssl 1.1.1 and it causes problems with the installation of ruby versions older than 3.02 (information actual 6/20/2023).
2. Keep in mind that these 2 apps will interact with each other, the purpose of the Core app is for populating DB only. AACT-admin uses the same db as AACT-core. Do not try to "rails s" AACT-core.
3. In those 2 lines in the environment variables file: 
`export AACT_CORE_DATABASE_URL=postgres://username:passw@localhost:5432/aact`
`export AACT_CORE_TEST_DATABASE_URL=postgres://username:passw@localhost:5432/aact_test` 
username - your Postgresql DB username 
passw - your postgres DB password

## Getting Started

1.  Install PostgreSQL
    `brew install postgresql`  
    https://www.postgresql.org/download/linux/ubuntu/  
    https://www.postgresql.org/download/macosx/  

2.  Create the roles you need for running AACT.  
    Enter `psql postgres` command in terminal to open postgres console and enter commands below to set up postgres database:  
    `postgres=# create role <your_aact_superuser> login password <your_superuser_password>;`  
    `postgres=# alter user <your_aact_superuser> with superuser;`  
    `postgres=# create role read_only;`  
    `postgres=# create database aact_alt;`  
    `postgres=# \q` this exits out of psql  
    Verify your new user can login to psql with command: `psql -U <your_aact_superuser> -d postgres` 
    OR use command `sudo -u postgres psql` for it. 
    You can exit the shell once you see you can log in.

   

3.  If your terminal asks for a password when logging in to psql you can give it the password automatically by adding it to the “.pgpass” file. If you haven’t been asked for a password, you can skip this step.
    The “.pgpass” should be at your root.  
    `echo 'localhost:5432:aact:<superuser_name>:<superuser_password>'  >> ~/.pgpass`  
    Now check that you can login to psql without giving a password  
    `psql -U <username> -d postgres`
    You can exit the shell once you see you can log in without a password.

    Here is a document about the “.pgpass” file https://www.postgresql.org/docs/current/libpq-pgpass.html.   

4.  Now we want to store the environmental variables for the superuser that you created in the previous step.     That is the user you will be using within AACT to make database changes. You can store these wherever is appropriate for your system. On a Mac you can store it in your “.zshrc”. On all systems you can also store it in your “.bash_profile” or “.bashrc”.  
    For the following commands I’m storing variables in the “.zshrc” file, change out that file in the commands for the one you use for storing variables.
    ```bash 
    echo 'export AACT_DB_SUPER_USERNAME=<your_aact_superuser>' >> ~/.zshrc
    echo 'export AACT_PASSWORD=<your_superuser_password>'  >> ~/.zshrc
    echo 'export PUBLIC_DB_USER=<your_aact_superuser>'  >> ~/.zshrc
    echo 'export PUBLIC_DB_PASS=<your_superuser_password>'  >> ~/.zshrc
    # for development
    echo 'export AACT_USERNAME=<your_superuser_name>'  >> ~/.zshrc 
    echo 'export AACT_PASSWORD=<your_superuser_password>'  >> ~/.zshrc
    echo 'export AACT_ADMIN_USERNAME=<username for aact_admin database>'  >> ~/.zshrc    
    echo 'export AACT_ADMINPASSWORD=<password for aact_admin database>'  >> ~/.zshrc   
    echo 'export AACT_PUBLIC_USERNAME=<username for aact_public database>'  >> ~/.zshrc    
    echo 'export AACT_PUBLIC_PASSWORD=<password for aact_public database>'  >> ~/.zshrc    

    source ~/.zshrc # to load the variables into the terminal session.
    ```
    
    Depending on where you store the variables you may need to call `source` on that file each time you open a new terminal. This is not necessary for “.zshrc”.
     When you're done check your “.zshrc” or ".bashrc" file. It should look like the example below. If it doesn't, edit it accordingly. 

    Example of a set of environment variables: 

```bash
export AACT_PASSWORD=54104754
export AACT_USERNAME=user_name
export PGPASSWORD=passw
export TEST_PUBLIC_DB_USER=user_name
export TEST_PUBLIC_DB_PASS=passw
export PUBLIC_DB_USER=user_name
export PUBLIC_DB_PASS=passw
export AACT_DB_SUPER_USERNAME=user_name
export PATH=$PATH:/lib/postgresql/15/bin
export AACT_CORE_DATABASE_URL=postgres://DB_USER_NAME:DB_PASSW@localhost:5432/aact
export AACT_CORE_TEST_DATABASE_URL=postgres://DB_USER_NAME:DB_PASSW@localhost:5432/aact_test
```

Add RVM to PATH for scripting. Make sure this is the last PATH variable change. 

`export PATH="$PATH:$HOME/.rvm/bin"`

Ask teamleader for keys instead of 'XXXXXX...' 

```bash
export DIGITALOCEAN_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXXXXXX
export DIGITALOCEAN_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXX 
export DIGITALOCEAN_REGION=nyc3
export DIGITALOCEAN_BUCKET=aact-dev
```

5.  Clone this repo: `git clone git@github.com:ctti-clinicaltrials/aact.git`  
    Note: Cloning with a ssh url requires that your local ssh key is saved to Github. The key verifies your permission to push and pull so you won't have to log in. If you haven't saved your ssh key to Github use the html url instead when cloning.  

6.  `cd aact` to enter the directory  

7.  Install a ruby version manager like rbenv, then install Ruby 2.7.7  

8.  Bundle install  
    The pg gem (used by AACT) may have trouble finding your PostgreSQL installation. If not, skip this step.  
    For Mac you can direct it to the right location location by adding  
    `echo ‘export PATH=$PATH:/Library/PostgreSQL/x.y/bin’  >> ~/.zshrc` change x.y to the version number of your PostgreSQL installation.  
    Example: `export PATH=$PATH:/Library/PostgreSQL/13/bin`  
    https://wikimatze.de/installing-postgresql-gem-under-ubuntu-and-mac/  

9. In the database.yml file, which is in config folder, lines 1-32 should look like:

```
default: &default
  encoding: utf8
  adapter: postgresql
  min_messages: warning
  pool: <%= [Integer(ENV.fetch("MAX_THREADS", 50)), Integer(ENV.fetch("DB_POOL", 50))].max %>
  timeout: 5000
  
  //  Make sure you've created a database account for the AACT_DB_SUPER_USERNAME (default: aact) with permission to create databases.//
 
  // Also, add an entry for this user in the .pgpass file in the root directory of the user who run the rails apps so the app knows its password.//
  
  username: <%= ENV.fetch("AACT_DB_SUPER_USERNAME", 'your_db_username') %>

development:
  primary:
    <<: *default
    host: localhost
    port: 5432
    username: <%= ENV.fetch("AACT_USERNAME", 'your_db_username') %>
    password: <%= ENV.fetch("AACT_PASSWORD", 'your_password') %>
    database: aact
  admin:
    <<: *default
    host: localhost
    port: 5432
    username: <%= ENV.fetch("AACT_USERNAME", 'your_db_username') %>
    password: <%= ENV.fetch("AACT_PASSWORD", 'your_password') %>
    database: aact_admin
  public:
    <<: *default
    host: localhost
    port: 5432
    username: <%= ENV.fetch("AACT_USERNAME", 'your_db_username') %>
    password: <%= ENV.fetch("AACT_PASSWORD", 'your_password') %>
    database: aact_public
```
    
10. Create databases and run migrations  
    `bin/rake db:create`  
    `bin/rake db:create RAILS_ENV=test`  
    `bin/rake db:migrate`  
    `bin/rake db:migrate RAILS_ENV=test`  

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
* `bin/rake db:load_study[<nct_id>]` this will update only one study from the clinicaltrials.gov api 

<br>
<br>

***

<br>

 # Workflow
 ## Branches:
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

## API V2 Comparison Tool

When finishing a model, run the comparison using the following command:

`rake compare:v2_model[<NCTID>,<model>]``

for example:
```bash
  rake compare:v2_model[NCT06225401,study]
  rake compare:v2_model[NCT06225401,design]
```

This tool will tell you where there is a mismatch between version 1 and version 2 of the api