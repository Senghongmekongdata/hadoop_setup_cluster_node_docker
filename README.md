# 5-Node Distributed Hadoop & Spark Cluster (Docker)

Setting up a 5-node Hadoop cluster in Docker is an excellent way to simulate a distributed environment on a single machine.

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


## Launch the Cluster
Run the following command to start all 5 nodes (plus the management services):
```
# bash
docker-compose up -d
```

## Verify the Installation
Once the containers are running, you can verify the status through your browser:
- **HDFS NameNode UI:** [http://localhost:9870](http://localhost:9870) (Check "Datanodes" tab to see all 4 workers).
- **YARN Resource Manager:** [http://localhost:8088](http://localhost:8088) (Check "Nodes" to see the active NodeManagers).


#### HDFS NameNode UP
<img width="1637" height="986" alt="image" src="https://github.com/user-attachments/assets/9d779eb2-fbc7-4f9d-8ee6-a357594fb007" />

#### YARN Resource Manager
<img width="1892" height="521" alt="image" src="https://github.com/user-attachments/assets/6196ccbc-9768-46b5-9a27-8aed2935ae1a" />


