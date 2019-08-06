# AACT
Database for Aggregated Analysis of ClinicalTrials.gov

## Purpose

This is a ruby on rails application that retreives all studies from ClinicalTrials.gov (via their API) and makes the information available in a relational database.  We do this to make this valuable body of information accessible to the public as a complete aggregated set of data.

If you need a copy of the database, but don't want to bother installing & running this app, copies of the database are available for download from the <a href='https://aact.ctti-clinicaltrials.org/snapshots' target='_blank'>AACT website (Download page).</a> We use pg_dump to create a snapshot of the database after each nightly update, so a version is always available with the most current info from ClinicalTrials.gov.

## Getting Started

These instructions assume you're on a Mac. Linux users will need to use yum or apt-get to install tools. (Apologies to Windows users.)

* If you don't already have standard development tools on your machine, this might help get you mostly setup: https://github.com/thoughtbot/laptop

## You'll need:

### git
*  <a href='https://git-scm.com/book/en/v2/Getting-Started-Installing-Git' target='_blank'>git</a> to clone the AACT application.

###  ruby
*  We recommend you use a ruby version manager. Popular ones are: <a href='http://rvm.io/' target='_blank'>rvm</a> & <a href='https://github.com/rbenv/rbenv' target='_blank'>rbenv</a>. We use <a href='https://github.com/postmodern/chruby' target='_blank'>chruby</a> because it is lightweight. (`brew install chruby`)
*  **ruby 2.4.5**  If using chruby, you can get it with the command: `ruby-install ruby 2.4.5`

### python
brew install python

### postgreSQL (supported: version 11.1)
If you don't already have postgres, you'll need to know a bit about setting up & administering it, particularly with respect to security.  In short, if you're installing on a Mac, basic steps to get started can be:

*  `brew install postgresql`
*  `brew services start postgresql`
*  `mkdir /usr/local/var/pg_data`
*  `initdb /usr/local/var/pg_data -E utf8`
*  `pg_ctl -D /usr/local/var/pg_data -l logfile start`

*  template1=# `create role <your_aact_pg_user> login password '<your_pg_password>';`
*  template1=# `alter user <your_aact_pg_user> with superuser;`
*  template1=# `create role read_only;`
*  template1=# `create database aact;`
*  template1=# `\q`  (quite out of postgres)

*  Create *.pgpass* in your root directory that contains line: `localhost:5432:*:<your_aact_pg_user>:<your_pg_password>`
*  `chmod 0600 .pgpass`  (set restrictive permissions on this file)
*  Verify your new user can login to postgres with command: `psql -U <your_aact_pg_user> -d template1`  

Note:  You could use other versions of postgres or a different relational database such as mysql. If so, you'll need to make changes to files in db/migrate & *app/models/util/db_manager.db* since it drops/creates indexes under assumption it's using postgres 11.1.

### Create directory for static files

AACT downloads the complete set of studies from ClinicalTrials.gov as a zipfile that contains an xml file for each study [[https://clinicaltrials.gov/search/resultsxml=true]].  Until recently, the ClinicalTrials.gov API only provided this info in XML format.  In June, 2019, an improved API was deployed in beta which provides a far more flexible way to retrieve studies from ClinicalTrials.gov and also lets you retrieve it as json.  [[https://clinicaltrials.gov/ct2/about-site/new]]

By default, AACT saves the downloaded xml file in a directory under /aact-files. (Note, this is in the server root directory, not the root of the AACT application.)  To override this, use the AACT_STATIC_FILE_DIR environment variable to define a different directory.  Otherwise, you will need to create /aact-files at the server root directory and change permissions on it so that the rails application owner has permission to read/write to that directory.

*  `sudo su`               # you need superuser rights to create the directory
*  `mkdir /aact-files`
*  `chown <your-system-account> /aact-files`
*  `chgrp <your-system-account> /aact-files`
*  `exit`                 # exit the superuser login

### Environment variables

Add the following to your shell profile (for example .bash_profile):

 | env var | default value | description |
 |---|:---:|---|
 |AACT_DB_SUPER_USERNAME | aact | Database user name responsible for creating and populating the AACT DB. Must have rights to create db. |
 |APPLICATION_HOST | localhost | Server where the system runs to load the database. |
 | AACT_PUBLIC_DATABASE_NAME | aact | Name of the database that will be available to users. |
 | AACT_BACK_DATABASE_NAME | aact_back | Name of the database that is the target for initially loading data from ClinicalTrials.gov |
 | AACT_ADMIN_DATABASE_NAME | aact_back | Name of the database that contains admin info such as users, public announcements, etc.  This is primarily to support the AACT website, but is also referred to by the load process, so we include it here. |
 | RACK_TIMEOUT | 10 | Number of seconds to wait before aborting requests that take too long. |
 | AACT_STATIC_FILE_DIR | /aact-files | Directory containing AACT static files such as the downloadable db snapshots. |

If you intend to populate a 'public' database on a different server from the one that performs the loads:
* export AACT_PUBLIC_HOSTNAME=*domain name of server*   (Set this to the domain name of the server that will host the database available to users.)

If you intend to send email notifications to yourself or others whenever a database load completes, you will need to set these variables:
* export AACT_OWNER_EMAIL=*<aact-sys@email.addr>*
* export AACT_ADMIN_EMAILS=*<your@email.addr>,<another-admin@email.addr>*

`source ~/.bash_profile` (Make these new environment variables available in your current session.)

## Install AACT

*  Clone this repo: `git clone git@github.com:ctti-clinicaltrials/aact.git`
*  Change into the AACT directory you just created: `cd aact`
*  `gem install bundler -v 1.9.0`
*  `bundle install`
*  `bundle exec rake db:create`   (create the database)
*  `bundle exec rake db:migrate`  (create tables, indexes, views, etc. in the database)
*  `bundle exec rake db:seed`     (Populate with sample data to verify it all works.)

## Import studies from clinicaltrials.gov

### Full import

`bash -l -c 'bundle exec rake full:load:run'`

The full import will download the entire dataset from clinicaltrials.gov; this takes about 20 minutes. When complete, it populates the study_xml_records table from the resulting file. Once that table's loaded with one row per study, it iterates thru each row in the table to parse the xml and saves study info to the appropriate tables.

### Daily import

`bash -l -c 'bundle exec rake incremental:load:run[days_back]'`

The daily import checks the ClinicalTrials.gov RSS feed for studies that have been added or changed. You can specify how many days back to look in the dataset with the `days_back` argument above. To import changed/new studies from two days back: `bash -l -c 'bundle exec rake incremental:load:run[2]'`

###  If you just want to load an existing copy of the database...

Download and unzip the file from the AACT website: https://aact.ctti-clinicaltrials.org/snapshots

If this is the first time & the aact database doesn't yet exist, use this command:

`pg_restore -c -C  -j 5 -v -U aact -d postgres --no-acl postgres_data.dmp &> pg_restore.log`

If you want to refresh the aact database you already have on your local machine:

`pg_restore -c -j 5 -v -U aact -d aact --no-acl postgres_data.dmp &> pg_restore.log`

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)

