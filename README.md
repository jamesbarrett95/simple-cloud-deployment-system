# simple-cloud-deployment-system

## Introduction

Given a runtime parameter N, this system automatically does the following:

1. Generate a random shared secret string and stores it in ```secretKey```,
2. Downloads and installs the server code (https://github.com/portsoc/clocoss-master-worker/), Node.js and Git.
3. Starts the server with ```secretKey``` as a parameter,
4. Creates N new gcloud VMs, providing to each the server's IP address and the ```secretKey```.
5. Each of the N VMs does the following:
  1. Downloads and installs the client software and its dependencies (Node.js an Git),
  2. Runs the client with the server's IP address and the ```secretKey``` as parameters,
  3. Shuts down when the client exits;
6. Finally, when the server exits, the system deletes all the client VMs and their disks.

## Documentation

```bash
git clone https://github.com/jamesbarrett95/simple-cloud-deployment-system;
cd simple-cloud-deployment-system;
sh index.sh [NUMBER_OF_WORKERS];
```
