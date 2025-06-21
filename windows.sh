#!/bin/bash

# SSH Key Location which is requied for logging into Raspberry Pi using SSH
KEY_LOCATION="/mnt/d/My_Projects/Project_Phase_2/mykeypair.pem"

# Details of Raspberry Pi
USERNAME="ubuntu"
IP_ADDRESS="3.110.12.149"

declare -a LOCAL_SOURCE=(
    [0]="/mnt/d/test_directory1/"
    [1]="/mnt/d/test_directory2/"
    [2]="/mnt/d/test_directory3/"
)

# declare -a REMOTE_DESTINATION=(
#     [0]="/mnt/raidMount"
#     [1]="/mnt/raidMount"
#     [2]="/mnt/raidMount"
# )

declare -a REMOTE_DESTINATION=(
    [0]="/home/ubuntu"
    [1]="/home/ubuntu"
    [2]="/home/ubuntu"
)


for ((i=0; i<${#LOCAL_SOURCE[@]}; i++));
do
    sudo rsync -avz -e "ssh -i $KEY_LOCATION" ${LOCAL_SOURCE[$i]} $USERNAME@$IP_ADDRESS:${REMOTE_DESTINATION[$i]}
done
