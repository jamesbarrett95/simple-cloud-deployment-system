#!/bin/bash

# Get number of VMs
N=$1;

# Storing a random password and worker name into variables
secretKey=`openssl rand -base64 32`;
workerName="james-barrett-worker";

# Installing Node and Git
echo "Installing dependencies...";
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - &> /dev/null
sudo apt-get -qq install nodejs &> /dev/null
sudo apt-get -qq install git &> /dev/null
echo "...Dependencies installed.";

# Cloning Clocoss Master Worker from GitHub
echo "Cloning master worker...";
git clone --quiet https://github.com/portsoc/clocoss-master-worker &> /dev/null
cd clocoss-master-worker;
echo "Installing master worker...";
npm install --silent

# Configure our gcloud zone
gcloud config set compute/zone europe-west1-d;

echo "Creating $N instance(s)...";

# Creating gcloud VMs
for i in `seq 1 $N`;
do
        gcloud compute instances create "$workerName"-"$i" \
        --machine-type f1-micro \
        --tags http-server,https-server \
        --metadata secret=$secretKey,ip=`curl -s -H "Metadata-Flavor: Google" \
                                               "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"` \
        --metadata-from-file \
          startup-script=../startup-script.sh
done;

echo "Starting server.";
npm run server $secretKey;

echo "Removing server code...";
cd ..;
sudo rm clocoss-master-worker -r;
echo "Server removed!";

echo "Killing workers...";
for i in `seq 1 $N`;
do
        gcloud compute instances delete "$workerName"-"$i" --quiet;
done;

echo "Workers terminated";