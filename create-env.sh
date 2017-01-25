#!/bin/bash

if [ "$#" -eq 6 ]

then

echo "Image ID: $1"
echo "Key Name: $2"
echo "Security group ID: $3"
echo "Launch-Configuration-Name: $4"
echo "Count: $5"
echo "IAM Profile Name:$6"

aws ec2 run-instances --image-id $1 --key-name $2 --security-group-ids $3 --instance-type t2.micro --placement AvailabilityZone=us-west-2b --count $5 --user-data file://install-app.sh --iam-instance-profile Name="$6" 

cloud=`aws ec2 describe-instances  --query 'Reservations[*].Instances[].InstanceId' --filters "Name=instance-state-name, Values=pending"`

aws ec2 wait instance-running --instance-ids $cloud

aws elb create-load-balancer --load-balancer-name itmo544-cloudvipul --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --availability-zones us-west-2b

#aws ec2 wait instance-running --instance-ids $cloud

aws elb register-instances-with-load-balancer --load-balancer-name itmo544-cloudvipul --instances $cloud

aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name $2 --instance-type t2.micro --user-data file://install-app.sh

aws autoscaling create-auto-scaling-group --auto-scaling-group-name cloudserverdemo --launch-configuration-name $4 --availability-zones us-west-2b --load-balancer-name itmo544-cloudvipul --max-size 5 --min-size 0 --desired-capacity 1

aws ec2 run-instances --image-id $1 --key-name $2 --security-group-ids $3 --instance-type t2.micro --count $5 --user-data file://cronjob.sh --iam-instance-profile Name="$6"
else

echo "Enter Proper Parameters"
exit 1

fi
