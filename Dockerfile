FROM ruby:2.7.7

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client telnet vim zip cron graphviz wget

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install bundler -v 1.17.3
RUN bundle install

# Create non-root user and set ownership and permissions as required
RUN adduser --disabled-password aact && chown -R aact /app

COPY . /app


# Switch to the user
USER aact

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b" "0.0.0.0"]