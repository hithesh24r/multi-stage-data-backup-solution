#!/bin/bash
sudo su
sudo apt update
sudo apt upgrade -y
sudo apt install php-cli -y
sudo snap install nextcloud

# DECLARING REQUIRED VARIABLES
USERNAME="nextcloud"
PASSWORD="nextcloud"
DOMAIN="nextcloud.hithesh24r.xyz"

USER1="USER1"
USER2="USER2"
USER3="USER3"
PASSWORD1="USER1_PASSWORD"
PASSWORD2="USER2_PASSWORD"
PASSWORD3="USER3_PASSWORD"

BUCKET_NAME="nextcloud-hithesh24r-admin"
ACCESS_KEY=""
SECRET_ACCESS_KEY=""
REGION="ap-south-1"
S3_ENDPOINT="s3-website.ap-south-1.amazonaws.com"
NEXTCLOUD_GROUP="users"

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

# CREATING AND ALLOTING PERMISSIONS TO USERS AND GROUPS
sudo snap run nextcloud.occ group:add $NEXTCLOUD_GROUP

export OC_PASS=$PASSWORD1
snap run nextcloud.occ user:add --password-from-env --display-name="$USER1" --group=$NEXTCLOUD_GROUP $USER1

export OC_PASS=$PASSWORD2
snap run nextcloud.occ user:add --password-from-env --display-name="$USER2" --group=$NEXTCLOUD_GROUP $USER2

export OC_PASS=$PASSWORD3
snap run nextcloud.occ user:add --password-from-env --display-name="$USER3" --group=$NEXTCLOUD_GROUP $USER3

# For HTTPS Encryption on nextcloud
# sudo nextcloud.enable-https lets-encrypt

sudo snap run nextcloud.occ app:install previewgenerator
sudo snap run nextcloud.occ app:enable previewgenerator
sudo snap run nextcloud.occ config:app:set --value="64 256 1024" previewgenerator squareSizes
sudo snap run nextcloud.occ config:app:set --value="64 256 1024" previewgenerator widthSizes
sudo snap run nextcloud.occ config:app:set --value="64 256 1024" previewgenerator heightSizes
sudo snap run nextcloud.occ preview:generate-all -vvv

SCRIPT_PATH="/home/ubuntu/preview-gererator.sh"
touch $SCRIPT_PATH
chmod +x $SCRIPT_PATH
cat > $SCRIPT_PATH << EOL
sudo snap run nextcloud.occ preview:pre-generate
EOL

(crontab -l ; echo "*/10 * * * * $SCRIPT_PATH") | crontab -
