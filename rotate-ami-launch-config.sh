#!/bin/bash

oldconfigname="$1"
newconfigname="$2"
ami="$3"

KEYNAME="my_keypair_name"
ASGROUP="my_autoscaling_group_name"
SECURITYGROUP="sg-1234"
INSTANCETYPE="t2.micro"

if [ "$oldconfigname" = "" ]; then
    echo "Usage: ./rotate-ami-launch-config.sh <old_launch_config_name> <new_launch_config_name> <new_ami_id>"
    exit
fi
if [ "$newconfigname" = "" ]; then
    echo "Usage: ./rotate-ami-launch-config.sh <old_launch_config_name> <new_launch_config_name> <new_ami_id>"
    exit
fi
if [ "$ami" = "" ]; then
    echo "Usage: ./rotate-ami-launch-config.sh <old_launch_config_name> <new_launch_config_name> <new_ami_id>"
    exit
fi

echo "Creating new launch configuration"
aws autoscaling create-launch-configuration \
    --launch-configuration-name "$newconfigname" \
    --key-name "$KEYNAME" \
    --image-id "$ami" \
    --instance-type "$INSTANCETYPE" \
    --security-groups "$SECURITYGROUP" \
    --block-device-mappings "[{\"DeviceName\": \"/dev/xvda\",\"Ebs\":{\"VolumeSize\":8,\"VolumeType\":\"gp2\",\"DeleteOnTermination\":true}}]"

echo "Updating autoscaling group"
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "$ASGROUP" \
    --launch-configuration-name "$newconfigname"

echo "Deleting old launch configuration"
aws autoscaling delete-launch-configuration --launch-configuration-name "$oldconfigname"

echo "Finished"
