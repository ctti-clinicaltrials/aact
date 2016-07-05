FROM ruby:2.2.3
MAINTAINER Darin London <darin.london@duke.edu>

RUN /usr/bin/apt-get update && \
  /usr/bin/apt-get install -y postgresql libpq-dev libqt4-core \
  libqt4-dev nodejs zip

#miscellaneous
RUN ["mkdir","-p","/var/www/app"]
RUN ["gem", "install", "bundler"]
WORKDIR /var/www/app
ADD Gemfile /var/www/app/Gemfile
ADD Gemfile.lock /var/www/app/Gemfile.lock
RUN ["bundle", "install", "--jobs=4"]

# run the app by defualt
EXPOSE 3000
CMD ["rails","s"]
