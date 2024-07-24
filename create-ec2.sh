#!/bin/bash

instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")
domain_name="mahidevops.cloud"
hosted_zone_id="Z09453352UCEVDC5QWJID"

for name in ${instances[0]}; do
    if [ $name == "shipping" ] || [ $name == "mysql" ]
    then
        instance_type="t3.medium"
    else
        instance_type="t3.micro"
    fi

    echo "Creating Instance for: $name with instance type: $instance_type"
    instance_id=$(aws ec2 run-instances --image-id ami-041e2ea9402c46c32 --instance-type $instance_type --security-group-ids sg-06c77e5ebcb730f00 --subnet-id subnet-0d875d9d4e0920075 --query 'Instances[0].InstanceId' --output text)
    echo "Instance created for: $name"

    aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$name

    if [ $name == "web" ]
    then
        aws ec2 wait instance-running --instance-ids $instance_id
        public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        ip_to_use=$public_ip
    else
        private_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        ip_to_use=$private_ip
    fi

    echo "Creating R53 record for: $name"

    aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id '
    {
        "Comment": "Creating a record set for '$name'"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$name.$domain_name'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$ip_to_use'"
            }]
        }
        }]
    }'


done

