ARG java_image_tag=8-jre

FROM eclipse-temurin:${java_image_tag}

# Hadoop
ENV HADOOP_VERSION=3.2.2
ENV HADOOP_HOME=/usr/hadoop
RUN curl --progress-bar -L --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
 && mv "/usr/hadoop-${HADOOP_VERSION}" "${HADOOP_HOME}" \
 && rm -rf "${HADOOP_HOME}/share/doc" \
 && chown -R root:root "${HADOOP_HOME}"

# Hive
ENV HIVE_VERSION=3.1.2
ENV HIVE_HOME=/usr/hive
ENV HIVE_CONF_DIR="${HIVE_HOME}/conf"
RUN curl --progress-bar -L \
  "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
    | gunzip \
    | tar -x -C /usr/ \
  && mv "/usr/apache-hive-${HIVE_VERSION}-bin" "${HIVE_HOME}" \
  && chown -R root:root "${HIVE_HOME}" \
  && mkdir -p "${HIVE_HOME}/hcatalog/var/log" \
  && mkdir -p "${HIVE_HOME}/var/log" \
  && mkdir -p "${HIVE_CONF_DIR}" \
  && chmod 777 "${HIVE_HOME}/hcatalog/var/log" \
  && chmod 777 "${HIVE_HOME}/var/log"
RUN rm /usr/hive/lib/guava-19.0.jar && cp /usr/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar /usr/hive/lib

# Spark
ENV SPARK_VERSION=3.3.0
ENV SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop3"
ENV SPARK_HOME=/usr/spark
RUN curl --progress-bar -L --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv "/usr/${SPARK_PACKAGE}" "${SPARK_HOME}" \
 && chown -R root:root "${SPARK_HOME}"
# For inscrutable reasons, Spark distribution doesn't include spark-hive.jar
# Livy attempts to load it though, and will throw
# java.lang.ClassNotFoundException: org.apache.spark.sql.hive.HiveContext
ARG SCALA_VERSION=2.11
RUN curl --progress-bar -L \
    "https://repo1.maven.org/maven2/org/apache/spark/spark-hive_${SCALA_VERSION}/${SPARK_VERSION}/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar" \
    --output "${SPARK_HOME}/jars/spark-hive_${SCALA_VERSION}-${SPARK_VERSION}.jar"

RUN apt-get update && apt-get install -y vim net-tools python3-pip
RUN pip3 install jinja-cli
RUN apt-get purge -y python3-pip
