#!/bin/bash

if [ $# -eq 2 ]

then

echo "Hello World" 

aws rds create-db-instance --db-instance-identifier itmo544-cloudvipul --allocated-storage 5 --db-instance-class db.t1.micro --engine mysql --master-username clouddatabase --master-user-password cloud123 --db-name school

aws rds wait db-instance-available --db-instance-identifier itmo544-cloudvipul

#Create Read Replica
aws rds create-db-instance-read-replica --db-instance-identifier itmo544-cloudvipul-readreplica --source-db-instance-identifier itmo544-cloudvipul

echo "Creating SNS Topic"
aws sns create-topic --name my-topic
snsarn=$(aws sns list-topics | cut -f 2)
aws sns subscribe --topic-arn $snsarn --protocol sms --notification-endpoint 1-312-937-5292

echo "Creating SQS Queue"
aws sqs create-queue --queue-name MyQueue

echo "Creating a Bucket"
aws s3 mb s3://$1 --region us-west-2 
aws s3 mb s3://$2 --region us-west-2 

else

echo "Enter Bucket Names"
exit 1

fi
