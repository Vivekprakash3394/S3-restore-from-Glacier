#!/bin/bash

prodProfile="--profile abc-onelogin"
s3_bucket_name="abc-prod-snapshots"

#read -p "Backup file name : " backupFileName
bucketName="abc-prod-snapshots/prod/backup-prod-2022-01-01-16-s3/abc/public.user_communication_log/"
keyData="abc-prod/backup-prod-2022-01-01-16-s3/abc/public.user_communication_log/"
aws s3 ls $bucketName $prodProfile | sed -e 's/^[[:space:]]*//' | cut -d " " -f 2 > tableName.txt

file="tableName.txt"
while read -r line; 
do
    awscli=$(aws s3 ls $bucketName$line $prodProfile | grep parquet | awk '{print $4}')
	  echo $awscli > abc.txt
    tr ' ' '\n' < abc.txt > newabc.txt
    Pfile="newabc.txt"
    while read -r pline;
    do
	  echo $keyData$line$pline
    echo $keyData$line$pline >> fullPath.txt
    done <$Pfile
done <$file

s3file="fullPath.txt"
while read -r pline;
do
  echo "Restore $pline GLACIER Object to S3 Standard Tier for Days 7"
  restore_Command=$(aws s3api restore-object --bucket $s3_bucket_name --key $pline --restore-request '{"Days":7,"GlacierJobParameters":{"Tier":"Standard"}}' $prodProfile)
  $restore_Command
  echo "$pline has been completed" >> s3_restore.log
done <$s3file
echo "Script Completed !!!"
exit 0
