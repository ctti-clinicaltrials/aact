#!/bin/bash

backup_time=`date +%Y%m%d-%H:%M`
S3Bucket=ENV['S3_BUCKET_NAME']

pg_dump -Fc $RDS_DB_READONLY_DBNAME -h $RDS_DB_HOSTNAME -U $RDS_DB_SUPER_USERNAME --no-password | gzip -9 | \
  s3cmd put - s3://$S3_BUCKET_NAME/snapshots/${backup_time}_$RDS_DB_READONLY_DBNAME.gz

echo "Done"
