#!/bin/bash

aws ec2 run-instances --image-id ami-06b94666 --key-name cloudvipul --security-group-ids sg-edf82d94 --instance-type t2.micro --placement AvailabilityZone=us-west-2b --count 3 --client-token cloudvipulo544 --user-data file://installapp.sh 

cloud=`aws ec2 describe-instances  --query 'Reservations[*].Instances[].InstanceId' --filters "Name=instance-state-name, Values=pending"`

aws ec2 wait instance-running --instance-ids $cloud

aws elb create-load-balancer --load-balancer-name itmo544-cloudvipul --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --availability-zones us-west-2b

#aws ec2 wait instance-running --instance-ids $cloud

aws elb register-instances-with-load-balancer --load-balancer-name itmo544-cloudvipul --instances $cloud

aws autoscaling create-launch-configuration --launch-configuration-name cloudserver --image-id ami-06b94666 --key-name cloudvipul --instance-type t2.micro --user-data file://installapp.sh

aws autoscaling create-auto-scaling-group --auto-scaling-group-name cloudserverdemo --launch-configuration-name cloudserver --availability-zones us-west-2b --load-balancer-name itmo544-cloudvipul --max-size 5 --min-size 0 --desired-capacity 1


