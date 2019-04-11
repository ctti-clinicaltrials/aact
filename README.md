# AACT
Database of Aggregated Analysis of ClinicalTrials.gov

## Purpose

This is a ruby on rails application that retreives the content of ClinicalTrials.gov (via their API) and makes the information available in a relational database as a complete aggregate set so that we can look at it as a whole, helping us investigate the clinical trials industry.

## Getting Started

#### You will need:

*  ruby 2.4.0
*  rails 4.2
*  postgres 11.1 (You could use other database platforms, but would need to make changes to app/models/util/db_manager.db since it drops/creates indexes on the assumption that it's dealing with a postgres database.)

This might help setup your machine:

[this script]: https://github.com/thoughtbot/laptop

####Install AACT:

*  Clone this repo.
*  Run this setup script: ./bin/setup

## Environment variables

After running `bin/setup`, you'll have a `.env` file that contains an empty template for the environment variables you'll need. These variables are copied from `.env.example`

## Importing studies from clinicaltrials.gov

## Full import

`bash -l -c 'bundle exec rake full:load:run'`

The full import will download the entire dataset from clinicaltrials.gov.

## Daily import

`bash -l -c 'bundle exec rake incremental:load:run[days_back]'`

The daily import checks the ClinicalTrials.gov RSS feed for studies that have been added or changed. You can specify how many days back to look in the dataset with the `days_back` argument above. To import changed/new studies from two days back: `bundle exec rake incremental:load:run[2]`

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
