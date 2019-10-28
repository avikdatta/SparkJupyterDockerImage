FROM avikdatta/basejupyterdockerimage

LABEL MAINTAINER reach4avik@yahoo.com

ENV NB_USER vmuser

USER root
WORKDIR /root/

RUN mkdir -p /home/$NB_USER/tmp

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    openjdk-8-jre-headless \
    ca-certificates-java \
    screen \
    netcat \
    unzip \
    libatlas-base-dev \
    gfortran               \
    sqlite3                \
    libhdf5-serial-dev     \
    g++ \
    liblz4-dev \
    libigraph0-dev  && \
    apt-get purge -y --auto-remove  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /home/$NB_USER/tmp

USER $NB_USER
WORKDIR /home/$NB_USER

ENV PYENV_ROOT="/home/$NB_USER/.pyenv"   
ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
ENV PATH="$PYENV_ROOT/shims/:$PATH"


COPY environment.yml /home/$NB_USER/environment.yml
ENV PATH $PATH:/home/$NB_USER/miniconda3/bin/
RUN conda env create -q --file /home/$NB_USER/environment.yml
RUN echo "conda deactivate" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    source ~/.bashrc

RUN rm -rf /home/$NB_USER/.cache && \
    rm -rf /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/tmp
    
ENV APACHE_SPARK_VERSION 2.4.4
ENV HADOOP_VERSION 2.7

# Install Apache Spark
RUN  wget -q http://www-us.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    rm -f spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark


EXPOSE 8887
EXPOSE 4040

# Spark config
ENV SPARK_HOME /home/$NB_USER/spark
ENV HAIL_HOME $(pip show hail | grep Location | awk -F' ' '{print $2 "/hail"}')
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$HAIL_HOME/python
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
ENV PATH $PATH:$SPARK_HOME/bin::$HAIL_HOME/bin/
ENV JAR_PATH $HAIL_HOME/hail-all-spark.jar
ENV PYSPARK_SUBMIT_ARGS "--conf spark.driver.extraClassPath='$JAR_PATH' --conf spark.executor.extraClassPath='$JAR_PATH' --conf spark.serializer=org.apache.spark.serializer.KryoSerializer  --conf spark.kryo.registrator=is.hail.kryo.HailKryoRegistrator pyspark-shell"

COPY entrypoint.sh /home/$NB_USER/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/home/$NB_USER/entrypoint.sh"]
CMD ["notebook"]
