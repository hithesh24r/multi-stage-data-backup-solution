#!/bin/bash

# SSH Key Location which is requied for logging into Raspberry Pi using SSH
KEY_LOCATION="/mnt/d/AWS_Access_Related/AWSKeyPair.pem"

# Details of Raspberry Pi
USERNAME="ubuntu"
IP_ADDRESS="13.127.181.167"

declare -a LOCAL_SOURCE=(
    [0]="/mnt/d/test_directory1/"
    [1]="/mnt/d/test_directory2/"
    [2]="/mnt/d/test_directory3/"
)

declare -a REMOTE_DESTINATION=(
    [0]="/mnt/raidMount"
    [1]="/mnt/raidMount"
    [2]="/mnt/raidMount"
)


for ((i=0; i<${#LOCAL_SOURCE[@]}; i++));
do
    sudo rsync -avz -e "ssh -i $KEY_LOCATION" ${LOCAL_SOURCE[$i]} $USERNAME@$IP_ADDRESS:${REMOTE_DESTINATION[$i]}
done
