#!/bin/bash
set -e
if [ "$POSTGRES_DEV_DB" ]; then
			psql --username $POSTGRES_USER <<-EODSQL
				CREATE DATABASE "$POSTGRES_DEV_DB" ;
			EODSQL
			echo
else
  # The - option suppresses leading tabs but *not* spaces. :)
  cat >&2 <<-NODEVWARN
****************************************************
WARNING: No POSTGRES_DEV_DB has been set.
         You should set this with
         "-e POSTGRES_DEV_DB=dbname" to set
         it in "docker run", and use the database
        entry in the database.yml development section.
****************************************************
NODEVWARN
fi
if [ "$POSTGRES_TEST_DB" ]; then
			psql --username $POSTGRES_USER <<-EOTSQL
				CREATE DATABASE "$POSTGRES_TEST_DB" ;
			EOTSQL
			echo
else
  # The - option suppresses leading tabs but *not* spaces. :)
  cat >&2 <<-NOTESTWARN
****************************************************
WARNING: No POSTGRES_TEST_DB has been set.
         You should set this with
         "-e POSTGRES_TEST_DB=dbname" to set
         it in "docker run", and use the database
        entry in the database.yml test section.
****************************************************
NOTESTWARN
fi
