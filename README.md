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

### postgreSQL (supported: version 11.1)
If you don't already have postgres, you'll need to know a bit about setting up & administering it, particularly with respect to security.  In short, if you're installing on a Mac, basic steps to get started can be:

*  `brew install postgresql`
*  `brew services start postgresql`
*  `psql -U postgres template1`
*  template1=# `create role <your_aact_pg_user> login password '<your_pg_password>';`
*  template1=# `alter user <your_aact_pg_user> with superuser;`
*  template1=# `create role read_only;`
*  template1=# `\q`  (quite out of postgres)

*  Create *.pgpass* in your root directory that contains line: `localhost:5432:*:<your_aact_pg_user>:<your_pg_password>`
*  `chmod 0600 .pgpass`  (set restrictive permissions on this file)
*  Verify your new user can login to postgres with command: `psql -U <your_aact_pg_user> -d template1`  

Note:  You could use other versions of postgres or a different relational database such as mysql. If so, you'll need to make changes to files in db/migrate & *app/models/util/db_manager.db* since it drops/creates indexes under assumption it's using postgres 11.1.

### Environment variables

Add the following to your shell profile (for example .bash_profile):

**Required variables:**
* export AACT_DB_SUPER_USERNAME=*<your_pg_user>*
* export AACT_ADMIN_EMAILS=*<your@email.addr>,<another-admin@email.addr>*

**Optional variables:**  (These default to the given value if you don't set them to something different.)
* export APPLICATION_HOST=*localhost*
* export AACT_PUBLIC_HOSTNAME=*localhost*   (Set this to the ip addr or domain name of the server that will host the database available to users.)
* export AACT_PUBLIC_DATABASE_NAME=*aact*   (Set this to the name of the database that will be the database available to users.)
* export AACT_BACK_DATABASE_NAME=*aact_back*  (Set this to the name of the database that does all the work to load data from ClinicalTrials.gov.)
* export AACT_ADMIN_DATABASE_NAME=*aact_admin*  (This database can contain anncillary tables such as users, public_announcements, etc. This is primarily to support the AACT website, but is also referred to by the load process, so we include it here.)
* export RACK_TIMEOUT=*20*
* export RAILS_SERVE_STATIC_FILES=*false*

`source ~/.bash_profile` (Make these new environment variables available in your current session.)

## Install AACT

*  Clone this repo: `git clone git@github.com:ctti-clinicaltrials/aact.git`
*  Change into the AACT directory you just created: `cd aact`
*  `gem install bundler -v 1.9.0`
*  `bundle install`
*  `bundle exec rake db:create`  (create the database)
*  `bundle exec rake db:migrate`  (create tables, indexes, views, etc. in the database)

## Import studies from clinicaltrials.gov

### Full import

`bash -l -c 'bundle exec rake full:load:run'`

The full import will download the entire dataset from clinicaltrials.gov; this takes about 20 minutes. When complete, it populates the study_xml_records table from the resulting file. Once that table's loaded with one row per study, it iterates thru each row in the table to parse the xml and saves study info to the appropriate tables.

### Daily import

`bash -l -c 'bundle exec rake incremental:load:run[days_back]'`

The daily import checks the ClinicalTrials.gov RSS feed for studies that have been added or changed. You can specify how many days back to look in the dataset with the `days_back` argument above. To import changed/new studies from two days back: `bash -l -c 'bundle exec rake incremental:load:run[2]'`

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)

