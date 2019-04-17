# AACT
Database for Aggregated Analysis of ClinicalTrials.gov

## Purpose

This is a ruby on rails application that retreives the content of ClinicalTrials.gov (via their API) and makes the information available in a relational database.  We do this to make this valuable body of information accessible to the public as a complete aggregated set of data.

If you need a copy of the database, but don't want to bother installing & running this app, copies of the database are available for download from the <a href='https://aact.ctti-clinicaltrials.org/snapshots' target='_blank'>AACT website (Download page).</a> We use pg_dump to create a snapshot of the database after each nightly update, so a version is always available with the most current info from ClinicalTrials.gov.

## Getting Started

These instructions assume you're on a Mac. Linux users will need to use yum or apt-get to install tools. (Apologies to Windows users.)

* If you don't already have standard development tools on your machine, this might help get you mostly setup: https://github.com/thoughtbot/laptop

### You'll need:

*  <a href='https://git-scm.com/book/en/v2/Getting-Started-Installing-Git' target='_blank'>git</a> to clone the AACT application.
*  We recommend a ruby version manager. Popular ones are: <a href='http://rvm.io/' target='_blank'>rvm</a> & <a href='https://github.com/rbenv/rbenv' target='_blank'>rbenv</a>. We use <a href='https://github.com/postmodern/chruby' target='_blank'>chruby</a> because it is lightweight.
*  **ruby 2.4.5**  If using chruby, you can get this version with the command: `ruby-install 2.4.5`
*  **postgres 11.1** `brew install postgresql`  You could use other versions of postgres or a different relational database such as mysql, but if so, you might need to make changes to files in db/migrate & will probably need to make a few changes to *app/models/util/db_manager.db* since it drops/creates indexes thinking it's dealing with postgres 11.1.
*  **wget** if you don't already have it: `brew install wget`

### Setup Basic Environment Variables

In your shell profile file (for example .bash_profile), define the following:

* export AACT_DB_SUPER_USERNAME=(name of postgres database superuser.  example:  **postgres**)
* export AACT_BACK_DATABASE_URL=(name of postgres loading/staging AACT database.  example:  **aact_back**)
* export AACT_PUBLIC_DATABASE_URL=(name of postgres final/public AACT database.  example:  **aact**)

`source ~/.bash_profile` (Make these new environment variables available in your current session.)

### Install AACT:

*  Clone this repo: `git clone git@github.com:ctti-clinicaltrials/aact.git`
*  Change into the AACT directory: `cd aact`
*  Run this setup script: `./bin/setup`

### Environment variables

After running `bin/setup`, you'll have a `.env` file that contains an empty template for other environment variables you'll need. These variables are copied from `.env.example`

## Importing studies from clinicaltrials.gov

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

