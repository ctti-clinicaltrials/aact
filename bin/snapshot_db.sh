#!/bin/bash
export WORK_DIR=/app/tmp/aact-dumps
export DUMP_FILE_NAME=$WORK_DIR/db.dmp
export S3CMD_CFG_FILE=$WORK_DIR/s3cfg
export SCHEMA_DIAGRAM="https://s3.amazonaws.com/aact-prod/documentation/aact_schema.png"
export DATA_DICTIONARY="https://s3.amazonaws.com/aact-prod/documentation/aact_data_definitions.xlsx"

#  While testing, let this run on any day.
#ifStart=`date '+%d'`
#if [ $ifStart == 01  or $ifStart == 20 ]
#then
  rm -rf $WORK_DIR
  mkdir $WORK_DIR
  export BACKUP_TIME=`date +%Y%m%d`

   pg_dump -h $RDS_DB_HOSTNAME -p 5432 -U $RDS_DB_SUPER_USERNAME --no-owner --no-password --clean --exclude-table study_xml_records --exclude-table schema_migrations --exclude-table load_events  --exclude-table statistics --exclude-table sanity_checks --exclude-table use_cases --exclude-table use_case_attachments -c -C -Fc -f $DUMP_FILE_NAME  $RDS_DB_READONLY_DBNAME

  tar cvzf $DUMP_FILE_NAME, $SCHEMA_DIAGRAM, $DATA_DICTIONARY
  #gzip -9 $DUMP_FILE_NAME

  echo "[default]" > ${S3CMD_CFG_FILE}
  echo "access_key=${AWS_ACCESS_KEY_ID}" >> ${S3CMD_CFG_FILE}
  echo "secret_key=${AWS_SECRET_ACCESS_KEY}" >> ${S3CMD_CFG_FILE}

  s3cmd -c $S3CMD_CFG_FILE put ${DUMP_FILE_NAME}.gz \
    s3://$S3_BUCKET_NAME/snapshots/${BACKUP_TIME}_$RDS_DB_READONLY_DBNAME.gz
#else
#  echo "Not the first of the month, not running."
#fi

