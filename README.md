# Apache Spark Cluster Automation

This software tool automates the deployment of Spark-centric data analysis clusters. It integrates with Cloud Storage (Aliyun OSS), Hive Metastore, and Hue UI. The build and deployment are based on Docker and Kubernetes.

## Cloud Platform

### Cloud Object Storage

The deployment uses Cloud Object Storage services to store files, instead of HDFS. It supports the following services:
  - [Aliyun OSS](https://www.alibabacloud.com/product/object-storage-service)

## Software

It integrates with the following data analysis softwares:
  * Compute engines:
    * [Spark 3.3.0](https://spark.apache.org)
  * Metastores:
    * [Hive 3.1.2](http://hive.apache.org): Hive Metastore
  * UI:
    * [Hue](https://gethue.com/): UI of Spark and Hive Metastore
  * Others:
    * [Hadoop 3.2.2](http://hadoop.apache.org): provide various dependencies

Build & Deployment:
* [Docker](https://www.docker.com): build and manage images
* [Kubernetes](https://kubernetes.io): deploy softwares and services
* [minikube](https://minikube.sigs.k8s.io/docs/start/): for test purpose, simulate a Kubernetes cluster locally

## Quickstart

### Build Docker Images

The `docker` folder contains files for building Docker images.

The example uses three Docker images:
  * `datalab:latest`: running Spark and Hive Metastore (need to build)
  * `mysql:5.7.35`: running MySQL as the backend of Hive Metastore and Hue
  * `gethue/hue:latest`: running Hue

`datalab:latest` is based on the build scripts from https://github.com/panovvv/hadoop-hive-spark-docker. Run the following command to build `datalab:latest`:
```bash
cd docker/base
# The base image for installing softwares
docker build . -t datalab-base:latest
# The final image for configurations
cd ..
docker build . -t datalab:latest
```

### Setup Kubernetes Cluster

Have a Kubernertes cluster ready before proceeding. This example uses [minikube](https://minikube.sigs.k8s.io/docs/start/).

```bash
minikube start --memory 4096 --cpus 4
```

It is optional, we can use minikube's Docker so the local built images can be directly used in Kubernetes.
```bash
# use minikube’s Docker
eval $(minikube docker-env)
```

### Deploy Kubernetes Resources

The `k8s` folder contains files of Kubernetes configurations.

Start with creating a new namespace:
```bash
cd k8s
kubectl apply -f playground-ns.yaml
```

#### MySQL

This deployement uses a MySQL pod in the same cluster as the database of Hive Metastore and Hue. The following command deploys the pod and service:

```bash
kubectl apply -f mysql-pod.yaml
kubectl apply -f mysql-svc.yaml

# Check the `CLUSTER-IP` of `mysql-svc`, this is the IP of MySQL.
kubectl get svc -n playground
```

#### Spark and Hive Metastore

`cluster-config.yaml` provides a [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/) of all Spark and Hive Metastore configurations. The fields to fill are:
  * `<oss-directory>`: the [Aliyun OSS](https://www.alibabacloud.com/zh/product/object-storage-service) directory to store files
  * `<oss-key-id>` and `<oss-key-secret>`: the [Aliyun access key](https://www.alibabacloud.com/help/en/basics-for-beginners/latest/obtain-an-accesskey-pair) for auth
  * `<mysql-ip>`: the cluster IP of the MySQL pod

Run the following command to create the config map, pod, and service:
```bash
kubectl apply -f cluster-config.yaml
kubectl apply -f engines-pod.yaml
kubectl apply -f engines-svc.yaml

# Check the `CLUSTER-IP` of `engines-svc`, this is the IP of Spark and Hive (for Hue).
kubectl get svc -n playground
```

#### Hue

First create a database in MySQL called `hue` for Hue to use:
```bash
# Create a temporary MySQL client pod
kubectl exec --stdin --tty mysql -n playground -- bash

# In the temporary client pod
root@mysql: mysql -u root -p
mysql> CREATE DATABASE hue;
```

Similar to the config map used by Spark and Hive Metastore pod, `hue-configmap.yaml` is a config map for Hue. Fill in the fields:
  * `<mysql-ip>`: the cluster IP of the MySQL pod
  * `<engines-ip>`: the cluster IP of the Spark and Hive Metastore pod

Create the Hue pod and service:
```bash
kubectl apply -f hue-pod.yaml 
kubectl apply -f hue-svc.yaml 
```

Finally, open the Hue UI in your brower:
```bash
minikube service hue-svc -n playground
```
