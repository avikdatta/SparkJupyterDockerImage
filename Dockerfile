FROM avikdatta/basejupyterdockerimage:master

MAINTAINER reach4avik@yahoo.com

ENTRYPOINT []

ENV NB_USER vmuser

USER root
WORKDIR /root/

RUN mkdir -p /home/$NB_USER/tmp

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    openjdk-8-jre-headless \
    ca-certificates-java \
    screen \
    netcat \
    unzip \
    &&  apt-get purge -y --auto-remove  \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*

RUN rm -rf /home/$NB_USER/tmp

USER $NB_USER
WORKDIR /home/$NB_USER

ENV PYENV_ROOT="/home/$NB_USER/.pyenv"   
ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
ENV PATH="$PYENV_ROOT/shims/:$PATH"

RUN eval "$(pyenv init -)" 
RUN pyenv global 3.6.0

RUN pip install py4j \
                pyarrow \
                pandas \
                keras  \
                tensorflow \
                jupyter-tensorboard \
                numpy \
                matplotlib \
                seaborn \
                bokeh \
                parsimonious==0.8.0 \
                ipykernel \
                decorator==4.2.1

RUN rm -rf /home/$NB_USER/.cache && \
    rm -rf /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/tmp
    
ENV APACHE_SPARK_VERSION 2.2.2
ENV HADOOP_VERSION 2.7

# Install Apache Spark
RUN  wget -q http://www-us.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    rm -f spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

RUN wget -q https://storage.googleapis.com/hail-common/distributions/devel/Hail-devel-a06353b8f4bd-Spark-2.2.0.zip && \
    unzip Hail-devel-a06353b8f4bd-Spark-2.2.0.zip && \
    rm -f Hail-devel-a06353b8f4bd-Spark-2.2.0.zip
  
EXPOSE 8887
EXPOSE 4040

# Spark config
ENV SPARK_HOME /home/$NB_USER/spark
ENV HAIL_HOME /home/$NB_USER/hail
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$HAIL_HOME/python
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
ENV PATH $PATH:$SPARK_HOME/bin::$HAIL_HOME/bin/
ENV JAR_PATH $HAIL_HOME/jars/hail-all-spark.jar
ENV PYSPARK_SUBMIT_ARGS "--conf spark.driver.extraClassPath='$JAR_PATH' --conf spark.executor.extraClassPath='$JAR_PATH' pyspark-shell"

CMD ["jupyter","lab","--ip=0.0.0.0","--port=8887","--no-browser"]
