#!/bin/bash

backup_time=`date +%Y%m%d-%H:%M`
S3Bucket=ENV['S3_BUCKET_NAME']

pg_dump -Fc $DB_READONLY_DBNAME -h $DB_HOSTNAME -U $DB_SUPER_USERNAME --no-password | gzip -9 | \
  s3cmd put - s3://$S3_BUCKET_NAME/snapshots/${backup_time}_$DB_READONLY_DBNAME.gz

echo "Done"
