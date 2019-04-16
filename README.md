# AACT
Database for Aggregated Analysis of ClinicalTrials.gov

## Purpose

This is a ruby on rails application that retreives the content of ClinicalTrials.gov (via their API) and makes the information available in a relational database as a complete aggregate set so that we can study the info as a whole.

Please note: if you want to create & use a local copy of the AACT relational database, but would prefer not to install & run this app to create it, you can always download a copy of the database from the <a href='https://aact.ctti-clinicaltrials.org/snapshots' target='_blank'>AACT website download page.</a> A copy of the database is created/archived each night, so a version is available with the most current info from ClinicalTrials.gov.

## Getting Started

The following assumes you're on a Mac. Most of this will probably work on Linux too. (Apologies to Windows users.)

This might help setup many standard dev tools on your machine:
[this script]: https://github.com/thoughtbot/laptop
Install wget: `brew install wget`

### You will need:

*  <a href='https://git-scm.com/book/en/v2/Getting-Started-Installing-Git' target='_blank'>git</a>
*  <a href='https://github.com/postmodern/chruby' target='_blank'>chruby</a> (to manage ruby versions)
*  ruby 2.4.5
*  postgres 11.1 (You can use other versions of postgres or other relational database platforms such as mysql, but might need to make changes to app/models/util/db_manager.db since it drops/creates indexes on the assumption that it's dealing with postgres 11.1.)

### Setup Basic Environment Variables

In your shell profile file (for example .bash_profile), define the following

* export AACT_DB_SUPER_USERNAME=<name of postgres database superuser>
* export AACT_BACK_DATABASE_URL=<name of postgres loading/staging AACT database>
* export AACT_PUBLIC_DATABASE_URL=<name of postgres final/public AACT database>

`source ~/.bash_profile` (to bring newly created environment variables into your current session)

###Install AACT:

*  Clone this repo: `git clone git@github.com:ctti-clinicaltrials/aact.git`
*  Change into the AACT directory: `cd aact`
*  Run this setup script: `./bin/setup`

## Environment variables

After running `bin/setup`, you'll have a `.env` file that contains an empty template for the environment variables you'll need. These variables are copied from `.env.example`

## Importing studies from clinicaltrials.gov

## Full import

`bash -l -c 'bundle exec rake full:load:run'`

The full import will download the entire dataset from clinicaltrials.gov; this takes about 20 minutes. When complete, it populates the study_xml_records table from the resulting file. Once that table's loaded with one row per study, it iterates thru each row in the table to parse the xml and saves study info to the appropriate tables.

## Daily import

`bash -l -c 'bundle exec rake incremental:load:run[days_back]'`

The daily import checks the ClinicalTrials.gov RSS feed for studies that have been added or changed. You can specify how many days back to look in the dataset with the `days_back` argument above. To import changed/new studies from two days back: `bundle exec rake incremental:load:run[2]`

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
