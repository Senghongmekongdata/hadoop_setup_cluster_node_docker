# SETUP HADOOP AND SPARK WITH 5 CLSUTER NODE
This setup uses a "converged" architecture where the Master Node runs the NameNode and Spark Master, and the Worker Nodes run DataNodes and Spark Workers. This keeps the container count to exactly 5 while providing full functionality.


## 🏗️ Architecture Overview
- **NameNode (Master):** Manages HDFS metadata (Port: 9870)
- **ResourceManager (Master):** Schedules YARN jobs (Port: 8088)
- **4x DataNodes (Workers):** Store distributed data blocks.
---

## Prerequisites

### 1. Prerequisites
Before diving into Docker, ensure your host machine meets these minimum specs to handle 5 JVM-heavy containers:
- **RAM:** 16GB recommended (8GB minimum, but it will be sluggish).
- **Storage:** 10GB free space.
- **Docker Desktop:** Installed and running (Windows, macOS, or Linux).
  - [Download Docker Here!](https://drive.google.com/file/d/1ona6Jr7Fs5BdzujMF--ojkqZazoGv7Dw/view?usp=drive_link)
  - Or **Download with website:** [Docker](https://www.docker.com/products/docker-desktop/)
- **Docker Compose:** Usually bundled with Docker Desktop.

### 2. Check Pre-requirements
If you don't install or set up **WSL (Windows Subsystem for Linux)**, you primarily need to run a single command in an administrative terminal. This will enable the necessary Windows features and install the default Linux distribution (Ubuntu).
#### 1. Check Pre-requirements
Before starting, ensure your system is ready:
- **Virtualization:** Open Task Manager (Ctrl+Shift+Esc), go to the Performance tab, and select CPU. Ensure it says "Virtualization: Enabled".
  - **If disabled:** You must enable it in your computer's BIOS/UEFI settings (often under "Advanced" or "CPU Configuration" as VT-x or AMD-V).
- **Windows Version:** You need Windows 10 (version 2004 or higher) or Windows 11.
#### 2. The One-Command Setup
1. Right-click the Start button and select Terminal (Admin) or PowerShell (Admin).
2. Type the following command and press **Enter:**
```PowerShell
#PowerShell
wsl --install
```
3. Restart your computer when prompted.


#### 3. Initialize Your Linux Distro
After the restart, a Linux terminal window (Ubuntu) will open automatically to finish the installation.
- **Create a Username:** This can be anything (it doesn't have to match your Windows name).
- **Set a Password:** Type a password. Note: Characters won't appear as you type for security.
- **Update Packages:**
```bash
#bash
sudo apt update && sudo apt upgrade -y
```

#### 4. Verification
To ensure everything is running on the latest version (WSL 2), open PowerShell and run:
```bash
#PowerShell
wsl -l -v
```

## Project Directory Structure 
Create a folder named hadoop-spark-cluster and set up the following file structure inside it:
```
hadoop-spark-cluster/
├── Dockerfile -- Defines the "recipe" for building the single Docker image that every node in your cluster will use.
├── docker-compose.yml -- Describes the "infrastructure" of your cluster. It tells Docker how to spin up multiple instances of your image and how to network them.
└── entrypoint.sh -- A startup script that runs inside the container the moment it boots up. It decides "Who am I?" and starts the correct software.
```

## Setup Hadoop with Docker and WSL

### Step 1: Prepare the Directory (In WSL)
Open your WSL terminal (Ubuntu) and run these commands to start fresh:
```bash
#bash
cd ~
# If the folder exists, remove it to avoid conflicts (Optional)
# rm -rf hadoop-spark-cluster

mkdir hadoop-spark-cluster
cd hadoop-spark-cluster
mkdir -p data/namenode
mkdir -p data/datanode1 data/datanode2 data/datanode3 data/datanode4
```

### Step 2: Create the Dockerfile
This blueprint builds the OS, installs Java/Hadoop/Spark, and fixes Windows line-ending issues automatically.

Run: *nano Dockerfile* paste this content or open this with visual code:
```
#Dockerfile
FROM python:3.10-slim-bullseye

# 1. Install Java and Utilities
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless curl procps ssh net-tools && \
    rm -rf /var/lib/apt/lists/*

# 2. Set Environment Variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_VERSION=3.3.6
ENV SPARK_VERSION=3.5.0
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin

# 3. Install Hadoop
RUN curl -O https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -xzf hadoop-$HADOOP_VERSION.tar.gz -C /opt/ && \
    mv /opt/hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# 4. Install Spark
RUN curl -O https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop3.tgz && \
    tar -xzf spark-$SPARK_VERSION-bin-hadoop3.tgz -C /opt/ && \
    mv /opt/spark-$SPARK_VERSION-bin-hadoop3 $SPARK_HOME && \
    rm spark-$SPARK_VERSION-bin-hadoop3.tgz

# 5. Configure Hadoop Config Files (XML Injection)
# We hardcode /opt/hadoop in the XML values to ensure YARN containers find the path.
RUN echo '<configuration><property><name>fs.defaultFS</name><value>hdfs://namenode:9000</value></property></configuration>' > $HADOOP_HOME/etc/hadoop/core-site.xml && \
    echo '<configuration><property><name>dfs.replication</name><value>2</value></property><property><name>dfs.namenode.datanode.registration.ip-hostname-check</name><value>false</value></property></configuration>' > $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    echo '<configuration><property><name>mapreduce.framework.name</name><value>yarn</value></property><property><name>mapreduce.application.classpath</name><value>/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/mapreduce/lib/*</value></property><property><name>yarn.app.mapreduce.am.env</name><value>HADOOP_MAPRED_HOME=/opt/hadoop</value></property><property><name>mapreduce.map.env</name><value>HADOOP_MAPRED_HOME=/opt/hadoop</value></property><property><name>mapreduce.reduce.env</name><value>HADOOP_MAPRED_HOME=/opt/hadoop</value></property></configuration>' > $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    echo '<configuration><property><name>yarn.resourcemanager.hostname</name><value>namenode</value></property><property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property><property><name>yarn.nodemanager.env-whitelist</name><value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value></property></configuration>' > $HADOOP_HOME/etc/hadoop/yarn-site.xml

# 6. Configure Spark
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# 7. Add Entrypoint Script
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /root
ENTRYPOINT ["/entrypoint.sh"]
```
***(Save: Ctrl+O, Enter, Ctrl+X)***

### Step 3: Create the entrypoint.sh
This script handles the startup sequence for Master and Workers.

Run: nano entrypoint.sh Paste this content:
```
#bash
#!/bin/bash

# --- MASTER NODE ---
if [ "$ROLE" == "master" ]; then
    # Format only if the 'current' folder is missing (prevents data loss on restart)
    if [ ! -d "/tmp/hadoop-root/dfs/name/current" ]; then
        echo "Formatting NameNode..."
        $HADOOP_HOME/bin/hdfs namenode -format
    fi
    
    echo "Starting NameNode..."
    $HADOOP_HOME/bin/hdfs --daemon start namenode
    
    echo "Starting YARN ResourceManager..."
    $HADOOP_HOME/bin/yarn --daemon start resourcemanager

    echo "Starting Spark Master..."
    $SPARK_HOME/sbin/start-master.sh
fi

# --- WORKER NODES ---
if [ "$ROLE" == "worker" ]; then
    echo "Starting DataNode..."
    $HADOOP_HOME/bin/hdfs --daemon start datanode

    echo "Starting YARN NodeManager..."
    $HADOOP_HOME/bin/yarn --daemon start nodemanager
    
    echo "Starting Spark Worker..."
    $SPARK_HOME/sbin/start-worker.sh spark://namenode:7077
fi

tail -f /dev/null
```

### Step 4: Create the docker-compose.yml
This defines the network, the 5 nodes, and maps the storage volumes.

Run: nano docker-compose.yml Paste this content  or open this with visual code:
```
# YAML
version: '3'

services:
  namenode:
    build: .
    hostname: namenode
    container_name: hadoop-master
    environment:
      - ROLE=master
    ports:
      - "9870:9870" # HDFS Browser
      - "8080:8080" # Spark Master Browser
      - "8088:8088" # YARN Browser
      - "9000:9000" # HDFS RPC
      - "7077:7077" # Spark RPC
    volumes:
      - ./data/namenode:/tmp/hadoop-root/dfs/name
    networks:
      - hadoop_net

  datanode1:
    build: .
    container_name: hadoop-worker-1
    environment:
      - ROLE=worker
      - SPARK_WORKER_CORES=1
      - SPARK_WORKER_MEMORY=1G
    depends_on:
      - namenode
    volumes:
      - ./data/datanode1:/tmp/hadoop-root/dfs/data
    networks:
      - hadoop_net

  datanode2:
    build: .
    container_name: hadoop-worker-2
    environment:
      - ROLE=worker
    depends_on:
      - namenode
    volumes:
      - ./data/datanode2:/tmp/hadoop-root/dfs/data
    networks:
      - hadoop_net

  datanode3:
    build: .
    container_name: hadoop-worker-3
    environment:
      - ROLE=worker
    depends_on:
      - namenode
    volumes:
      - ./data/datanode3:/tmp/hadoop-root/dfs/data
    networks:
      - hadoop_net

  datanode4:
    build: .
    container_name: hadoop-worker-4
    environment:
      - ROLE=worker
    depends_on:
      - namenode
    volumes:
      - ./data/datanode4:/tmp/hadoop-root/dfs/data
    networks:
      - hadoop_net

networks:
  hadoop_net:
    driver: bridge
```
***(Save: Ctrl+O, Enter, Ctrl+X)***

### Step 5: Build and Run
To run docker, follow code bellow:
```
#bash
docker compose up -d --build --force-recreate
```

### Verification
1. Check Processes:Run docker ps. You should see 5 containers listed as Up.
2. Check Web UIs (Windows Browser):
   - HDFS: http://localhost:9870 (Go to "Datanodes" tab $\rightarrow$ Should see 4).
   - YARN: http://localhost:8088 (Look at "Active Nodes" $\rightarrow$ Should see 4).
   - Spark: http://localhost:8080 (Look at "Workers" $\rightarrow$ Should see 4).
  
