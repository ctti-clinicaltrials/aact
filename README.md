# AACT
Aggregated Analysis of ClinicalTrials.gov

## Getting Started

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

## Environment variables

After running `bin/setup`, you'll have a `.env` file that contains an empty template for the environment variables you'll need. These variables are copied from `.env.example`

## Importing studies from clinicaltrials.gov

### Full import

`bundle exec rake import:full:run`

The full import will download the entire dataset from clinicaltrials.gov. This rake task is designed to only work on the first of the month. To run the task and ignore the date, run `bundle exec rake import:full:run[force]`

### Daily import

`bundle exec rake import:daily:run[{days_back}]`

The daily import will check the RSS feed at clinicaltrials.gov for studies that have been added or changed. You can specify how many days back to look in the dataset with the `days_back` argument above. To import changed/new studies from two days back: `bundle exec rake import:daily:run[2]`

On Heroku, we use Heroku Scheduler to run these rake tasks on a recurring basis.


## Sanity checks

Sanity checks are a simple way for us to check that the tables in the database have been imported correctly and gives some insight into how the data looks at a high level. Both the daily and full import rake tasks run the sanity check automatically. To run it manually, open up a Rails console and enter `SanityCheck.run`. This will create a record in the `sanity_checks` table with a report represented in JSON.

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
