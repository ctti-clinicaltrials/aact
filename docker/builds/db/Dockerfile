FROM postgres:9.4
MAINTAINER Darin London <darin.london@duke.edu>
RUN ["/usr/sbin/usermod", "-G", "postgres,staff", "postgres"]
ADD docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
