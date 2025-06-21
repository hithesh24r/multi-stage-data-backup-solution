#!/bin/bash

# Updating and installing updates
sudo apt-get update
sudo apt-get upgrade -y

# Installing required packages
sudo apt install awscli -y
sudo apt install mdadm -y
sudo apt install rsync -y

# Configurign RAID 10 Array with 4 disks
yes | sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/xvdf /dev/xvdg
yes | sudo mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/xvdh /dev/xvdi
yes | sudo mdadm --create --verbose /dev/md10 --level=0 --raid-devices=2 /dev/md0 /dev/md1

sudo mkfs.ext4 /dev/md10
sudo mkdir "/mnt/raidMount"
sudo mount /dev/md10 "/mnt/raidMount"

BUCKET_NAME="nextcloud-hithesh24r-admin"
ACCESS_KEY="AKIAX75PSEIW6JASABX7"
SECRET_ACCESS_KEY="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"
REGION="ap-south-1"

sudo aws configure set aws_access_key_id $ACCESS_KEY
sudo aws configure set aws_secret_access_key $SECRET_ACCESS_KEY
sudo aws configure set default.region $REGION
sudo aws configure set default.output json

# Creating Script for RPi to S3 Synchronization
cat > /home/ubuntu/rpi_s3_sync.sh << EOL
#!/bin/bash

LOCAL_DIR="/mnt/raidMount/"
S3_BUCKET_NAME="nextcloud-hithesh24r-admin"

sudo mkdir \$LOCAL_DIR
aws s3 sync \$LOCAL_DIR s3://\$S3_BUCKET_NAME
EOL

chmod +x /home/ubuntu/rpi_s3_sync.sh

# Adding the synchronization script to cron jobs
(crontab -l ; echo "0 12 * * * \"/home/ubuntu/rpi_s3_sync.sh\"") | crontab -

# Testing S3 Sync
mkdir /home/ubuntu/mount_dir/

touch /home/ubuntu/mount_dir/test1.txt
touch /home/ubuntu/mount_dir/test2.py
touch /home/ubuntu/mount_dir/test3.xyz

aws s3 sync /home/ubuntu/mount_dir/ s3://$BUCKET_NAME

echo "${file(~/.ssh/id_rsa.pub)}" > /home/ubuntu/.ssh/authorized_keys