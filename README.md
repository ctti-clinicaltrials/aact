# AACT2
Aggregated Analysis of ClinicalTrials.gov

## Getting Started

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

## Environment variables

After running `bin/setup`, you'll have a `.env` file that has an empty template for the environment variables you'll need. These variables are copied from `.env.example`

## Importing studies from clinicaltrials.gov

### Full import

`bundle exec rake import:full:run`

The full import will download the entire dataset from clinicaltrials.gov. This rake task is designed to only work on the first of the month. To run the task and ignore the date, run `bundle exec rake import:full:run[force]`

### Daily import

`bundle exec rake import:daily:run[{days_back}]`

The daily import will check the RSS feed at clinicaltrials.gov for studies that have been added or changed. You can specify how many days back to look in the dataset with the `days_back` argument above. To import changed/new studies from two days back: `bundle exec rake import:daily:run[2]`

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
