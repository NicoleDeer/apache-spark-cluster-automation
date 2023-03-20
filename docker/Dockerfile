FROM datalab-base:latest

WORKDIR /home/datalab
ENV HOME="/home/datalab"

# Hadoop setup
ENV PATH="${PATH}:${HADOOP_HOME}/bin"
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"
ENV LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}"
ENV HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
ENV HADOOP_LOG_DIR="${HADOOP_HOME}/logs"
# For S3 to work. Without this line you'll get "Class org.apache.hadoop.fs.s3a.S3AFileSystem not found" exception when accessing S3 from Hadoop
ENV HADOOP_CLASSPATH="${HADOOP_HOME}/share/hadoop/tools/lib/*"

# COPY conf/hadoop/core-site.xml "${HADOOP_CONF_DIR}"
# COPY conf/hadoop/hadoop-env.sh "${HADOOP_CONF_DIR}"
COPY conf/hadoop/hdfs-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/mapred-site.xml "${HADOOP_CONF_DIR}"
COPY conf/hadoop/workers "${HADOOP_CONF_DIR}"
COPY conf/hadoop/yarn-site.xml "${HADOOP_CONF_DIR}"

RUN cd ${HADOOP_HOME}/share/hadoop/tools/lib && wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aliyun/3.3.4/hadoop-aliyun-3.3.4.jar

# Hive setup
ENV PATH="${PATH}:${HIVE_HOME}/bin"
ENV HADOOP_CLASSPATH="${HADOOP_CLASSPATH}:${HIVE_HOME}/lib/*"
# COPY conf/hive/hive-site.xml "${HIVE_CONF_DIR}/"
RUN cd ${HIVE_HOME}/lib && wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar

# Spark setup
ENV PATH="${PATH}:${SPARK_HOME}/bin"
ENV SPARK_CONF_DIR="${SPARK_HOME}/conf"
ENV SPARK_LOG_DIR="${SPARK_HOME}/logs"
ENV SPARK_DIST_CLASSPATH="${HADOOP_CONF_DIR}:${HADOOP_HOME}/share/hadoop/tools/lib/*:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/share/hadoop/yarn:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/*"
# COPY conf/hadoop/core-site.xml "${SPARK_CONF_DIR}"
COPY conf/hadoop/hdfs-site.xml "${SPARK_CONF_DIR}"
# COPY conf/spark/spark-defaults.conf "${SPARK_CONF_DIR}"
COPY conf/spark/spark-env.sh "${SPARK_CONF_DIR}"
COPY conf/spark/workers "${SPARK_CONF_DIR}"
# COPY conf/spark/hive-site.xml "${SPARK_CONF_DIR}"

COPY conf ${HOME}/conf

COPY entrypoint.sh ${HOME}
COPY entrypoint-hive.sh ${HOME}
RUN chmod +x ${HOME}/entrypoint.sh
