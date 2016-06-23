Development with Docker
-----------------------
We can use [Docker](https://www.docker.com/) to run, test, and debug our application. The following documents how to install and use
Docker on a Mac. There are [instructions](https://docs.docker.com/installation) for installing
and using docker on other operating systems.

On the mac, we use [docker for mac](https://docs.docker.com/docker-for-mac)

We use [docker-compose](https://docs.docker.com/compose/) to automate most of
our interactions with the application.

Docker Compose
--------------
This system contains two docker-compose.yml files:
  - docker-compose.yml: this is the default docker-compose.yml file. It
  provides access to the 'server' and 'db' (postgresql) services that are
  required to run the application. The server is is run on localhost:3000, and linked to the db internally.
  - docker-compose.dev.yml: allows the default docker-compose.yml file to be
  extended to add the ability to run rails, rake, and rspec.

In addition, the docker-compose.yml file expects two environment files to exist:
 - server.env
 - db.env

Each of these are symlinked by default to a .local.env file
that contains information relevant to the local dockerized
services. These can be changed to allow connections to
an external, or non-dockerized postgresql service.

Here is how you could run any docker-compose commands supported:

Build the server image (uses the Dockerfile in the root of the project)
```
docker-compose build
```
Once you have built the image, you can launch 'server' and 'db' containers
(docker calls a running instance of a docker image a docker container):

```
docker-compose up -d
```

You should now be able to
```
curl http://localhost:3000
```

Stop running containers
```
docker-compose stop
```

You can stop and delete the containers in one command using:
```
docker-compose down
```

A second yaml file has been placed in the application root, docker-compose.dev.yml.  

Here is a list of docker-compose commands available using this example
docker-compose.dev.yml:


Run the rspec (as RAILS_ENV=test)
```
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rspec
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rspec spec/requests
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rspec spec/models/survey_spec.rb
```

Run bundle install (you will need to do this even if you
have built the application, or the Gemfile.lock file will
not get updated to reflect the newly installed gems.):
```
docker-compose run -f docker-compose.yml -f docker-compose.dev.yml run bundle
```

Run rake commands (default RAILS_ENV=development):
```
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rake db:migrate
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rake db:seed
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rake db:migrate RAILS_ENV=test
```

Run rails commands (default RAILS_ENV=development):
```
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rails c
docker-compose -f docker-compose.yml -f docker-compose.dev.yml run rails c RAILS_ENV=docker_test
```

Launching the Application
-------------------------
You can build and launch the application using the following command:
```bash
docker-compose up -d
```
If you have not already migrated your migrations, you will then need to run:
```bash
docker-compose run -f docker-compose.yml -f docker-compose.dev.yml rake db:migrate
```

A shell script has been placed in this directory to make it easy for anyone
to launch the application, regardless of whether they have set their COMPOSE_FILE
environment variable or not.
```bash
./launch_application.sh
```

This will always launch the server and run rake dev:prime
