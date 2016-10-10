#! /bin/bash

aws autoscaling detach-load-balancers --auto-scaling-group-name cloudserverdemo --load-balancer-name itmo544-cloudvipul

aws autoscaling delete-auto-scaling-group --auto-scaling-group-name cloudserverdemo --force-delete

aws autoscaling delete-launch-configuration --launch-configuration-name cloudserver

cloud=`aws ec2 describe-instances  --query 'Reservations[*].Instances[].InstanceId' --filter "Name=instance-state-name, Values=running"`

aws elb deregister-instances-from-load-balancer --load-balancer-name itmo544-cloudvipul --instances $cloud

aws elb delete-load-balancer-listeners --load-balancer-name itmo544-cloudvipul --load-balancer-ports 80

aws elb delete-load-balancer --load-balancer-name itmo544-cloudvipul

aws ec2 terminate-instances --instance-ids $cloud

