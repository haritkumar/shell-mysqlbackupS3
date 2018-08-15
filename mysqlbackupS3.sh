#!/bin/bash
# Database credential
USER="username"
HOST="host-address"
DB_NAME="db-name"
DB_PASS="password"
DELET_RECORD_MIN=1

#Backup_Directory_Locations
TIMEZONE_SERVER=$(date +%Z)
BASE_FOLDER="/opt/backup"
BACKUPROOT=$BASE_FOLDER"/mysql_dump"
LOG_FOLDER=$BACKUPROOT"/logs"
TSTAMP=$(date +"%d-%b-%Y-%H-%M-%S")
S3BUCKET="s3://s3-bucket-name"

#logging
LOG_ROOT=$BACKUPROOT"/logs/"$TSTAMP"_dump_"$TIMEZONE_SERVER".log"

#Create folders
mkdir -p $BACKUPROOT

mkdir -p $LOG_FOLDER

#Dump of Mysql Database into S3\
echo "$(tput setaf 2) creating backup of database start at $TSTAMP" >> "$LOG_ROOT"

mysqldump -h $HOST -u $USER -p$DB_PASS $DB_NAME > $BACKUPROOT/$DB_NAME-$TSTAMP.sql

echo "$(tput setaf 3) Finished backup of database and sending it in S3 Bucket at $TSTAMP" >> "$LOG_ROOT"

s3cmd sync --delete-removed $BASE_FOLDER/ $S3BUCKET

echo "$(tput setaf 2) Moved the backup file from local to S3 bucket at $TSTAMP" >> "$LOG_ROOT"

echo "$(tput setaf 2) Deleting old files at $TSTAMP" >> "$LOG_ROOT"

find $BASE_FOLDER -type f -mmin +$DELET_RECORD_MIN -exec rm {} \;

echo "$(tput setaf 3) Coll!! Script have been executed successfully at $TSTAMP" >> "$LOG_ROOT"

###Save it and exit