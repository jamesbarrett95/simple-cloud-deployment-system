#!/bin/bash

# Get number of VMs
N=$1;

# Storing a random password and worker name into variables
secretKey=`openssl rand -base64 32`;
workerName="james-barrett-worker";

# Installing Node and Git
echo "Installing dependencies...";
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt-get -qq install nodejs;
sudo apt-get -qq install git;
echo "...Dependencies installed.";

# Cloning Clocoss Master Worker from GitHub
echo "Cloning master worker...";
git clone https://github.com/portsoc/clocoss-master-worker
cd clocoss-master-worker;
echo "Installing master worker...";
npm install;

# Configure our gcloud zone
gcloud config set compute/zone europe-west1-d;

# Curl google api endpoint to get the IP address
serverIP=`curl -s -H "Metadata-Flavor: Google" \
                "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"` \

# Creating gcloud VMs
echo "Creating $N VMs...";
for i in `seq 1 $N`;
do
        gcloud compute instances create "$workerName"-"$i" \
        --machine-type f1-micro \
        --tags http-server,https-server \
        --metadata secret=$secretKey,ip=$serverIP \
        --metadata-from-file \
          startup-script=../startup-script.sh
done;

# Start Master Worker Server
echo "Starting server...";
npm run server $secretKey;

# Remove Master Worker Code
echo "Removing server code...";
cd ..;
sudo rm clocoss-master-worker -r;
echo "Server removed!";

# Kill gcloud VMs
echo "Killing workers...";
for i in `seq 1 $N`;
do
        gcloud compute instances delete "$workerName"-"$i";
done;

echo "Workers terminated";