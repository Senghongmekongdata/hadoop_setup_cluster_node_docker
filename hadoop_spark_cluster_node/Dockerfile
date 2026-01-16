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
