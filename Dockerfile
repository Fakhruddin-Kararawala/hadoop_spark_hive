FROM ubuntu:latest

MAINTAINER Fakhruddin Kararawala <fakhruddin.kararawala [at] quickbuild.in>

# install base
RUN apt-get update && apt-get -y install \
    apt-utils \
    curl \
    wget \
    git \
    htop \
    vim \
    rsync \
    gnupg \
    dirmngr \
    libmysql-java

# install python
RUN apt-get install -y python

# Install Java.
FROM openjdk:8

# download hadoop
RUN \
    echo "Download Hadoop(3.2.0)" && wget -q -O /root/hadoop.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz && \
    echo "untar file" && cd /root && tar zxf hadoop.tar.gz && mv hadoop-3.2.0 /usr/local/hadoop

# download spark
RUN \
    echo "Download Spark(2.4.3)" && wget -q -O /root/spark-bin-hadoop.tgz https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz && \
    echo "untar file" && cd /root && tar -zxvf spark-bin-hadoop.tgz && mv spark-2.4.3-bin-hadoop2.7 /usr/local/spark

# download hive
RUN \
    echo "Download Hive(3.0.0)" && wget -q -O /root/hive-bin.tar.gz https://archive.apache.org/dist/hive/hive-3.0.0/apache-hive-3.0.0-bin.tar.gz && \
    echo "untar file" && cd /root && tar zxf hive-bin.tar.gz && mv apache-hive-3.0.0-bin /usr/local/hive

# install ssh
RUN apt-get update && apt-get install -y openssh-server openssh-client

#configure ssh free key access
ADD config/ssh_config /usr/local/
RUN mkdir /var/run/sshd && \
ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
mv /usr/local/ssh_config ~/.ssh/config && \
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# copy hadoop configs
ADD config/root_bashrc_hadoop.source /root/.bashrc
RUN mkdir /etc/hadoop	
ADD config/etc_hadoop_core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
ADD config/etc_hadoop_yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
ADD config/etc_hadoop_mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
ADD config/etc_hadoop_hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
ADD config/etc_hadoop_capacity-scheduler.xml /usr/local/hadoop/etc/hadoop/capacity-scheduler.xml
RUN mkdir -p /data/yarn/nodemanager/log /data/yarn/nodemanager/data /data/hdfs/datanode /data/hdfs/namenode
RUN mkdir -p /data/transfert
ADD config/hive-site.xml /usr/local/spark/conf/hive-site.xml
ADD config/hive-site.xml /usr/local/hive/conf/hive-site.xml

# slave management
ADD config/etc_hadoop_slaves /etc/hadoop/slaves

# copy example files
RUN mkdir /example
ADD example/fichier.txt /example/fichier.txt
ADD example/mapper.py /example/mapper.py
ADD example/reducer.py /example/reducer.py
RUN chmod a+x /example/*.py

# install spark
ADD config/SPARK_HOME_conf_spark-env.sh /usr/local/spark/conf/spark-env.sh
    

# Mysql jdbc dependency for hive metastore
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz && tar -xvf mysql-connector-java-5.1.48.tar.gz && \
    cp mysql-connector-java-5.1.48/mysql-connector-java-5.1.48.jar /usr/local/hive/lib/

# add start script
ADD docker/start.sh /root/start.sh
RUN chmod u+x /root/start.sh

# install data
VOLUME ["/data"]

# Expose ports
# hdfs port
EXPOSE 9000
EXPOSE 8020
# namenode port
EXPOSE 50070
# Resouce Manager
EXPOSE 8032
EXPOSE 8088
# MapReduce JobHistory Server Web UI
EXPOSE 19888
# MapReduce JobHistory Server
EXPOSE 10020
# Hive Server
EXPOSE 9083

CMD [ "/root/start.sh", "-d"]
