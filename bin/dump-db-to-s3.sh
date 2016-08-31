#!/bin/bash
export WORK_DIR=/app/tmp/aact-dumps
export DUMP_FILE_NAME=$WORK_DIR/db.dmp
export S3CMD_CFG_FILE=$WORK_DIR/s3cfg

rm -rf $WORK_DIR
mkdir $WORK_DIR

export BACKUP_TIME=`date +%Y%m%d-%H:%M`

ifStart=`date '+%d'`

if [ $ifStart == 01 ]
then
  pg_dump -Fc $RDS_DB_READONLY_DBNAME -h $RDS_DB_HOSTNAME \
    -U $RDS_DB_SUPER_USERNAME --no-password -f $DUMP_FILE_NAME

  gzip -9 $DUMP_FILE_NAME

  echo "[default]" > ${S3CMD_CFG_FILE}
  echo "access_key=${AWS_ACCESS_KEY_ID}" >> ${S3CMD_CFG_FILE}
  echo "secret_key=${AWS_SECRET_ACCESS_KEY}" >> ${S3CMD_CFG_FILE}

  s3cmd -c $S3CMD_CFG_FILE put ${DUMP_FILE_NAME}.gz \
    s3://$S3_BUCKET_NAME/snapshots/postgres.$RDS_DB_READONLY_DBNAME.dump.${BACKUP_TIME}.gz
else
  echo "Not the first of the month, not running."
fi
