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
