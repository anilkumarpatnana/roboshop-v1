#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="roboshop.anilkumarpatnana.online"
hosted_zone_id="Z0932076Y9TWK3RWNWAE"

update_records(){ 
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --change-batch "{
        \"Changes\": [{
            \"Action\": \"UPSERT\",
            \"ResourceRecordSet\": {
                \"Name\": \"$instance.$domain_name\",
                \"Type\": \"A\",
                \"TTL\": 300,
                \"ResourceRecords\": [{
                    \"Value\": \"$ip\"
                }]
            }
        }]
}"
}



for instance in "$@"
do
    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --security-groups "roboshop-common-ssh" "roboshop-$instance" \
        --count 1 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
    
    echo "Your instance ID of $instance is $instance_id"

    if [ "$instance" = "frontend" ]; then
        ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)

      echo "Your $instance public IP is: $ip"
     
      update_records   ###Calling function
   
      echo "Your route53 record $instance.$domain_name updated with Your $instance ip : $ip"
    
  else
        ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)

      echo "Your $instance private IP is: $ip"

      update_records   ###Calling function
   

      echo "Your route53 record $instance.$domain_name updated with Your $instance ip : $ip"
fi
done
