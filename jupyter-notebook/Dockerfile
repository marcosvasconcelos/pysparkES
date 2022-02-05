# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Provide passwordless 
RUN \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \  
    chmod g+w /etc/passwd

# Spark dependencies
ENV APACHE_SPARK_VERSION=3.0.0 \
    HADOOP_VERSION=3.2

RUN apt-get -y update
RUN apt-get -y install openjdk-11-jdk
RUN apt-get -y install gcc python-dev python3-dev python3-thriftpy python-thriftpy
RUN rm -rf /var/lib/apt/lists/*

# Install packages for HBase connection
# RUN apt-get -y install gcc
# RUN apt-get -y install python-dev
# RUN apt-get -y install python3-thriftpy
# RUN apt-get -y install python-thriftpy
RUN pip install pip -U
RUN pip3 install pip -U
RUN pip install happybase
RUN pip3 install happybase

# Using the preferred mirror to download Spark
WORKDIR /tmp
# https://archive.apache.org/dist/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz
# hadolint ignore=SC2046
RUN wget -q https://archive.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN tar xzf "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /usr/local --owner root --group root --no-same-owner
RUN rm "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

WORKDIR /usr/local
RUN ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" spark

# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9-src.zip
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info"
ENV  PATH=$PATH:$SPARK_HOME/bin
COPY ./es-lib/* $SPARK_HOME/jars/ 

COPY ./cacerts /usr/lib/jvm/java-1.11.0-openjdk-amd64/lib/security/
ENV PYSPARK_DRIVER_PYTHON_OPTS=notebook

USER $NB_UID

# Install pyarrow
RUN conda install --quiet -y 'pyarrow' && \
    conda clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
WORKDIR $HOME
COPY ./python-class-json-render.ipynb /home/${NB_USER}
COPY hbase-sample-data_manipulation.ipynb /home/${NB_USER}

