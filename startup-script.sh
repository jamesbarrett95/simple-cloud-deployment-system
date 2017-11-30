#!/bin/bash

# Install Git and Node for each VM
echo "Installing dependencies...";
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt-get install -y nodejs;
sudo apt-get install -y git;
echo "...Dependencies installed.";

# Install Master Worker from GitHub for each VM
echo "Downloading Worker";
git clone https://github.com/portsoc/clocoss-master-worker;
cd clocoss-master-worker;
npm install;
echo "...Worker downloaded.";

# Get server parameters
echo "Retrieving server parameters...";
secretKey=`curl -s -H "Metadata-Flavor: Google"  \
           "http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret"`;
serverip=`curl -s -H "Metadata-Flavor: Google"  \
   "http://metadata.google.internal/computeMetadata/v1/instance/attributes/ip"`;

# Run server for our VM!
echo "Starting worker for VM ";
npm run client $secretKey $serverip:8080;