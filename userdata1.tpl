#!/bin/bash
# https://github.com/nextcloud-snap/nextcloud-snap/wiki/Managing-HTTP-encryption-(HTTPS)

sudo su
sudo apt update
sudo apt upgrade -y
sudo apt install php-cli -y
sudo snap install nextcloud

# DECLARING REQUIRED VARIABLES
USERNAME="nextcloud"
PASSWORD="nextcloud"
DOMAIN="testing.hithesh24r.xyz"

MOUNT_POINT="ExternalMount"
BUCKET_NAME="my-backup-hithesh24r"
ACCESS_KEY=""
SECRET_ACCESS_KEY=""
REGION="ap-south-1"
S3_ENDPOINT="s3-website.ap-south-1.amazonaws.com"

# NEXTCLOUD INSTALLATION AND CONFIGURATION
useradd $USERNAME
echo $USERNAME:$PASSWORD | chpasswd
usermod -aG sudo $USERNAME
sudo nextcloud.manual-install $USERNAME $PASSWORD
sudo nextcloud.occ config:system:get trusted_domains
sudo nextcloud.occ config:system:set trusted_domains 1 --value=$DOMAIN
sudo snap set nextcloud php.memory-limit=512M
sudo snap set nextcloud nextcloud.cron-interval=10m
sudo snap install core
sudo snap refresh core

# NEXTCLOUD:EXTERNAL STORAGE SETUP
sudo snap run nextcloud.occ
sudo snap run nextcloud.occ app:install files_external
sudo snap run nextcloud.occ app:enable files_external

sudo snap run nextcloud.occ files_external:create $MOUNT_POINT amazons3 amazons3::accesskey --config bucket=$BUCKET_NAME --config key=$ACCESS_KEY --config secret=$SECRET_ACCESS_KEY --config hostname=$S3_ENDPOINT --config region=$REGION
sudo snap run nextcloud.occ files_external:list
sudo snap run nextcloud.occ files_external:option 1 mounted true

