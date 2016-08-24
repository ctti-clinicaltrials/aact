#!/bin/bash
echo "Starting sample Heroku bash job - test Heroku Scheduler..."
ls /app/tmp
echo "Write test file to Heroku FS..."
touch /app/tmp/sample-export.dmp
ls /app/tmp
echo "Clean up test file..."
rm /app/tmp/sample-export.dmp
echo "Done"
