#!/bin/bash

set -e

# Render and copy configs.
# Hadoop
jinja -d /config/config.json -o ${HADOOP_CONF_DIR}/core-site.xml ${HOME}/conf/hadoop/core-site.xml.j2
# Hive
jinja -d /config/config.json -o ${HIVE_CONF_DIR}/hive-site.xml ${HOME}/conf/hive/hive-site.xml.j2
# Spark
cp ${HADOOP_CONF_DIR}/core-site.xml ${SPARK_CONF_DIR}/core-site.xml
jinja -d /config/config.json -o ${SPARK_CONF_DIR}/hive-site.xml ${HOME}/conf/spark/hive-site.xml.j2
jinja -d /config/config.json -o ${SPARK_CONF_DIR}/spark-defaults.conf ${HOME}/conf/spark/spark-defaults.conf.j2

schematool -dbType mysql -validate || schematool -dbType mysql -initSchema

echo "Starting Hive Metastore ..."
hive --service metastore &

echo "Starting Hive Server ..."
hiveserver2 &

echo "Starting Spark ..."
${SPARK_HOME}/sbin/start-master.sh
${SPARK_HOME}/sbin/start-worker.sh spark://localhost:7077
${SPARK_HOME}/sbin/start-thriftserver.sh --master spark://localhost:7077

while true
do
  echo "Waiting ..."
  sleep 30
done
