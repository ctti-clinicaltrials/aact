# AACT2

## Getting Started

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

## Importing studies from clinicaltrials.gov

Start with opening `rails console`.

Call `client = ClinicalTrials::Client.new(search_term: 'your search term')`. To run without a search term, you can call `ClinicalTrials::Client.new`. This will download the ENTIRE clinicaltrials.gov database, and will take much longer (~1 hour).

Run `client.download_xml_files` to populate the database with the raw XML files from clinicaltrials.gov.

Run `client.populate_studies` to populate the database with studies and all their related records.

To determine the run time of the import, run `ClinicalTrials::LoadEvent.last(2)`. The first record will show the time it took to download the raw XML, the second record will show the time to populate the study records in the db.

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
