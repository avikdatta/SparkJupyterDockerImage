FROM avikdatta/basejupyterdockerimage

MAINTAINER reach4avik@yahoo.com

ENTRYPOINT []

ENV NB_USER vmuser

USER root
WORKDIR /root/

RUN add-apt-repository ppa:webupd8team/java \
    && apt-get -y update \
    && apt-get install -y oracle-java8-installer \
                          oracle-java8-set-default
                          
RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" > /etc/environment \
    && echo "JRE_HOME=/usr/lib/jvm/java-8-oracle/jre" >> /etc/environment
    
USER $NB_USER
WORKDIR /home/$NB_USER

ENV PYENV_ROOT="/home/$NB_USER/.pyenv"   
ENV PATH="$PYENV_ROOT/libexec/:$PATH" 
ENV PATH="$PYENV_ROOT/shims/:$PATH"

RUN eval "$(pyenv init -)" 
RUN pyenv global 3.5.2

RUN pip install pandas
        
ENV APACHE_SPARK_VERSION 2.2.0
ENV HADOOP_VERSION 2.7

# Install Apache Spark v 2.1.0
RUN  wget -q https://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark


EXPOSE 8888
EXPOSE 4040

# Spark config
ENV SPARK_HOME /home/$NB_USER/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
ENV PATH $PATH:$SPARK_HOME/bin

CMD ["jupyter-notebook", "--ip", "0.0.0.0"]
