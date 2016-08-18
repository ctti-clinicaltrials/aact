# AACT2
Aggregated Analysis of ClinicalTrials.gov

## Getting Started

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

## Importing studies from clinicaltrials.gov

Start by opening `rails console`.

To load the full clinicaltrials.gov database, call `client = ClinicalTrials::Client.new`.

Run `client.download_xml_files` to populate the database with the raw XML files from clinicaltrials.gov. This is will take ~2 hours.

Run `client.populate_studies` to populate the database with studies and all their related records. This will take ~12 hours

To determine the run time of the import, run `ClinicalTrials::LoadEvent.last(2)`. The first record will show the time it took to download the raw XML, the second record will show the time to populate the study records in the db.

If you want to run this with a subset of the data, you can instantiate the client with a `search_term`: `ClinicalTrials::Client.new(search_term: 'pancreatic cancer.')`

### Incremental load
Coming soon

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
