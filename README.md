# AACT2

## Getting Started

After you have cloned this repo, run this setup script to set up your machine
with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

### Error tracking and monitoring

Log into [AppSignal](https://appsignal.com/) and create a new app. Follow the steps they provide and run the generator. Replace the hard coded API key with `ENV['APPSIGNAL_API_KEY']`. Add the key to `.env`.

### CI

Log into [CircleCI](https://circleci.com) and create a new project that points to the Github repo.

## Importing studies from clinicaltrials.gov

Start with opening `rails console`.

Call `client = ClinicalTrials::Client.new(search_term: 'your search term')`. To run without a search term, you can call `ClinicalTrials::Client.new`. This will download the ENTIRE clinicaltrials.gov database, and will take much longer (~1 hour).

Run `client.create_studies`. Duplicates will not be re-created.

To determine the run time of the import, run `ClinicalTrials::LoadEvent.last(2)`. The first record will show the time it took to download the file, the second record will show the time to populate the study records in our db.

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
