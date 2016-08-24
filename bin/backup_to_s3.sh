#!/bin/bash

backupTime=`date +%Y%m%d-%H:%M`
S3Bucket=aact2

pg_dump -Fc $RDS_DB_READONLY_DBNAME -h $RDS_DB_HOSTNAME -U $RDS_DB_SUPER_USERNAME --no-password | gzip -9 | \
  s3cmd put - s3://$S3_BUCKET_NAME/snapshots/postgres.$RDS_DB_READONLY_DBNAME.dump.${backupTime}.gz

echo "Done"
