#!/bin/bash

backupTime=`date +%Y%m%d-%H:%M`
S3Bucket=aact2
RDSHostname=aact2-main.cbj0v72pdrrv.us-east-1.rds.amazonaws.com
RDSUsername=garrettqmartin
RDSDatabaseName=aact2

pg_dump -Fc ${RDSDatabaseName} -h ${RDSHostname} -U ${RDSUsername} --no-password | gzip -9 | \
  s3cmd put - s3://${S3Bucket}/snapshots/postgres.${RDSDatabaseName}.dump.${backupTime}.gz

echo "Done"
