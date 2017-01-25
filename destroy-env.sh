#! /bin/bash

#detach load balancers
aws autoscaling detach-load-balancers --auto-scaling-group-name cloudserverdemo --load-balancer-name itmo544-cloudvipul

#delete autoscaliing group
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name cloudserverdemo --force-delete

#delete-launch-configuration
aws autoscaling delete-launch-configuration --launch-configuration-name cloudserver

#store instances in cloud variable
cloud=`aws ec2 describe-instances  --query 'Reservations[*].Instances[].InstanceId' --filter "Name=instance-state-name,
Values=running"`

# de register instances from load-balancer
aws elb deregister-instances-from-load-balancer --load-balancer-name itmo544-cloudvipul --instances $cloud

#delete-load-balancer-listeners
aws elb delete-load-balancer-listeners --load-balancer-name itmo544-cloudvipul --load-balancer-ports 80

#delete-load-balancer
aws elb delete-load-balancer --load-balancer-name itmo544-cloudvipul

#terminate instances
aws ec2 terminate-instances --instance-ids $cloud

#delete-database instance
aws rds delete-db-instance --db-instance-identifier itmo544-cloudvipul-read-replica --skip-final-snapshot
echo "Waiting for database to be terminated"
aws rds wait db-instance-deleted --db-instance-identifier itmo544-cloudvipul-read-replica
aws rds delete-db-instance --db-instance-identifier itmo544-cloudvipul --skip-final-snapshot
aws rds wait db-instance-deleted --db-instance-identifier itmo544-cloudvipul

#delete s3 bucket
aws s3 rb s3://raw-vip --force
aws s3 rb s3://raw-kot --force

#delete sns topic
ARN=`aws sns list-topics --query 'Topics[*]'.'TopicArn' | cut -d\" -f2`
aws sns delete-topic --topic-arn $ARN

#delete sqs queue
URL=`aws sqs get-queue-url --queue-name MyQueue --query 'QueueUrl' | cut -d\" -f2`
aws sqs delete-queue --queue-url $URL

echo "All Destroyed";
