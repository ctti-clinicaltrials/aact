# Aact2

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

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)
