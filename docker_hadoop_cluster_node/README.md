# HADOOP INSTALLATION WITH 5 NODES CLUSTERING
This is the repo for installing the docker with 5 cluster and hadoop componenet like HDFS, YARN, and MAPREDUCE


## 1. Prerequire for setting up docker
To make sure you can run and setup docker to install hadoop with 5 cluster nodes
- If you don't install wsl yet, please install this follow the script below:
```
wsl --install
```
- Make sure you have docker desktop install on your os (Window OS)

## 2. Install and Setup Hadoop Environment
Follow the steps below to setup your hadoop on your docker environment:

### 1. Create directory 
Prepare folder to set up the project environment 
```
# bash
-- access wsl env
wsl -- this will allow to access to Windows Subsystem for Linux (wsl)

-- create directory
mkdir hadoop-5-node
cd hadoop-5-node

-- after access to this directory, create file as below
docker-compose.yml
hadoop.env
```
