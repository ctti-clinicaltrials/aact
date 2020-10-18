FROM ruby:2.4.5

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client telnet vim zip

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . /app

RUN ln -s /config/connections.yml /app/config/connections.yml

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b" "0.0.0.0"]
