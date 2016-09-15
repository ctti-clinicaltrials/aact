#!/bin/bash
export WORK_DIR=/app/tmp/aact-dumps
export DUMP_FILE_NAME=$WORK_DIR/db.dmp
export S3CMD_CFG_FILE=$WORK_DIR/s3cfg

#  While testing, let this run on any day.
#ifStart=`date '+%d'`
#if [ $ifStart == 01  or $ifStart == 20 ]
#then
  rm -rf $WORK_DIR
  mkdir $WORK_DIR
  export BACKUP_TIME=`date +%Y%m%d`

   pg_dump -h $RDS_DB_HOSTNAME -p 5432 -U $RDS_DB_SUPER_USERNAME --no-owner --no-password --clean --exclude-table study_xml_records --exclude-table schema_migrations --exclude-table load_events  --exclude-table statistics --exclude-table sanity_checks -c -C -Fc -f $DUMP_FILE_NAME  $RDS_DB_READONLY_DBNAME

  gzip -9 $DUMP_FILE_NAME

  echo "[default]" > ${S3CMD_CFG_FILE}
  echo "access_key=${AWS_ACCESS_KEY_ID}" >> ${S3CMD_CFG_FILE}
  echo "secret_key=${AWS_SECRET_ACCESS_KEY}" >> ${S3CMD_CFG_FILE}

  s3cmd -c $S3CMD_CFG_FILE put ${DUMP_FILE_NAME}.gz \
    s3://$S3_BUCKET_NAME/snapshots/${BACKUP_TIME}_$RDS_DB_READONLY_DBNAME.gz
#else
#  echo "Not the first of the month, not running."
#fi

