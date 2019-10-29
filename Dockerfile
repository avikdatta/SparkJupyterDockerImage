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

ENV TINI_VERSION v0.18.0
RUN wget --quiet  https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    mv tini /usr/local/bin/tini && \ 
    chmod +x /usr/local/bin/tini
    
USER $NB_USER
WORKDIR /home/$NB_USER

COPY environment.yml /home/$NB_USER/environment.yml
ENV PATH $PATH:/home/$NB_USER/miniconda3/bin/
RUN conda env create -q --file /home/$NB_USER/environment.yml
RUN echo "source deactivate" >> ~/.bashrc && \
    echo "source activate pipeline-env" >> ~/.bashrc && \
    conda clean -i -t -q -y && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/.cache

#ENV APACHE_SPARK_VERSION 2.4.4
#ENV HADOOP_VERSION 2.7
# Install Apache Spark
#RUN  wget -q http://www-us.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
#    tar -xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
#    rm -f spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
#    mv spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

EXPOSE 8887
EXPOSE 4040

COPY entrypoint.sh /home/$NB_USER/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD ["source ~/.bashrc && bash /home/vmuser/entrypoint.sh notebook"]
