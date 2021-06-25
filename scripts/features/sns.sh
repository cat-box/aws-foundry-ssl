#!/bin/bash
source /foundryssl/variables.sh

# check if topic_arn is empty
if [ ! -z "${topic_arn}" ]
then
    ec2id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
    message="Your Foundry EC2 server ${ec2id} has been active for over 24 hours."

    crontab -l | { cat; echo "0 */24 * * *    aws sns publish --topic-arn ${topic_arn} --message \"${message}\" --region ${region} 2>&1"; } | crontab -
fi