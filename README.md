# 5-Node Distributed Hadoop & Spark Cluster (Docker)

This project provides a fully functional, distributed Big Data environment using Docker. It includes a 5-node Hadoop cluster (1 Master, 4 Workers) integrated with Apache Spark, Hive, and Jupyter Notebook for interactive data analysis.

## 🏗️ Architecture Overview
- **NameNode (Master):** Manages HDFS metadata (Port: 9870)
- **ResourceManager (Master):** Schedules YARN jobs (Port: 8088)
- **3x DataNodes (Workers):** Store distributed data blocks.
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

## 🚀 Set up Docker
We will use a docker-compose.yml file to orchestrate the services. This setup uses pre-configured images from the Big Data Europe repository, which are stable and widely used for learning.

### Step 1: Create a project folder
```
#bash
mkdir hadoop-cluster
mkdir config
```

### Step 2: Define the Configuration
Hadoop requires specific XML files to communicate between nodes. Create an environment file named config/hadoop.env to simplify the Docker setup:

**File:** *config/hadoop.env*
```
CORE-SITE.XML_fs.defaultFS=hdfs://namenode:9000
HDFS-SITE.XML_dfs.replication=3
MAPRED-SITE.XML_mapreduce.framework.name=yarn
YARN-SITE.XML_yarn.resourcemanager.hostname=resourcemanager
YARN-SITE.XML_yarn.nodemanager.aux-services=mapreduce_shuffle
```

### Step 3: Create the Docker Compose File
This file defines the 5 containers (1 NameNode/ResourceManager and 4 DataNodes).
**File:** docker-compose.yml
```
version: "3"
services:
  namenode:
    image: apache/hadoop:3.3.6
    hostname: namenode
    container_name: namenode
    command: ["hdfs", "namenode"]
    ports:
      - "9870:9870" # HDFS Web UI
      - "9000:9000" # NameNode RPC
    env_file:
      - ./config/hadoop.env
    environment:
      ENSURE_NAMENODE_DIR: "/tmp/hadoop-root/dfs/name"

  resourcemanager:
    image: apache/hadoop:3.3.6
    hostname: resourcemanager
    container_name: resourcemanager
    command: ["yarn", "resourcemanager"]
    ports:
      - "8088:8088" # YARN Web UI
    env_file:
      - ./config/hadoop.env

  datanode1: &datanode_template
    image: apache/hadoop:3.3.6
    command: ["hdfs", "datanode"]
    env_file:
      - ./config/hadoop.env
    depends_on:
      - namenode

  datanode2:
    <<: *datanode_template
  datanode3:
    <<: *datanode_template
  datanode4:
    <<: *datanode_template

  nodemanager1: &nodemanager_template
    image: apache/hadoop:3.3.6
    command: ["yarn", "nodemanager"]
    env_file:
      - ./config/hadoop.env
    depends_on:
      - resourcemanager

  nodemanager2:
    <<: *nodemanager_template
  nodemanager3:
    <<: *nodemanager_template
  nodemanager4:
    <<: *nodemanager_template
```

### Step 4: Launch the Cluster
Run the following command to start all 5 nodes (plus the management services):
```
# bash
docker-compose up -d
```

### Step 5: Verify the Installation
Once the containers are running, you can verify the status through your browser:
- **HDFS NameNode UI:** [http://localhost:9870](http://localhost:9870) (Check "Datanodes" tab to see all 4 workers).
- **YARN Resource Manager:** [http://localhost:8088](http://localhost:8088) (Check "Nodes" to see the active NodeManagers).


#### HDFS NameNode UP
<img width="1637" height="986" alt="image" src="https://github.com/user-attachments/assets/9d779eb2-fbc7-4f9d-8ee6-a357594fb007" />

#### YARN Resource Manager
<img width="1892" height="521" alt="image" src="https://github.com/user-attachments/assets/6196ccbc-9768-46b5-9a27-8aed2935ae1a" />


