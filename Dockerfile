FROM imperialgenomicsfacility/base-notebook-image:release-v0.0.3
LABEL MAINTAINER 'reach4avik@yahoo.com'
ENV NB_USER vmuser
ENV NB_UID 1000
USER root
WORKDIR /root/
RUN mkdir -p /home/$NB_USER/tmp && \
    apt-get update && \
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
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /home/$NB_USER/tmp
RUN rm -rf /home/$NB_USER/Dockerfile && \
    rm -rf /home/$NB_USER/environment.yml && \
    rm -rf /home/$NB_USER/examples && \
    rm -rf /home/$NB_USER/entrypoint.sh
COPY Dockerfile /home/$NB_USER/Dockerfile
COPY examples /home/$NB_USER/examples
COPY environment.yml /home/$NB_USER/environment.yml
COPY entrypoint.sh /home/$NB_USER/entrypoint.sh
RUN chown -R ${NB_UID} /home/$NB_USER && \
    chown -R ${NB_UID} /home/$NB_USER/examples && \
    chmod a+r /home/$NB_USER/environment.yml && \
    chmod a+r /home/$NB_USER/entrypoint.sh && \
    rm -rf /tmp/*
USER $NB_USER
WORKDIR /home/$NB_USER
ENV PATH $PATH:/home/$NB_USER/miniconda3/bin/
RUN . /home/vmuser/miniconda3/etc/profile.d/conda.sh && \
    conda config --set safety_checks disabled && \
    conda update -n base -c defaults conda && \
    conda activate notebook-env && \
    conda env update -q -n notebook-env --file /home/$NB_USER/environment.yml && \
    conda clean -a -y && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter serverextension enable --sys-prefix jupyter_server_proxy && \
    jupyter serverextension enable --py jupyter_spark && \
    jupyter contrib nbextension install --user && \
    jupyter nbextension install --py jupyter_spark --user && \
    jupyter nbextension enable --py jupyter_spark && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter labextension install jupyterlab_sparkmonitor && \
    jupyter serverextension enable --py sparkmonitor && \
    ipython profile create --ipython-dir=/home/$NB_USER/.ipython && \
    echo "c.InteractiveShellApp.extensions.append('sparkmonitor.kernelextension')" >>  /home/$NB_USER/.ipython/profile_default/ipython_config.py && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/.cache
RUN wget -q -O /home/$NB_USER/zeppelin-0.9.0-preview2-bin-all.tgz \
  http://apache.mirror.anlx.net/zeppelin/zeppelin-0.9.0-preview2/zeppelin-0.9.0-preview2-bin-all.tgz && \
  tar -xf /home/$NB_USER/zeppelin-0.9.0-preview2-bin-all.tgz && \
  rm -rf /home/$NB_USER/zeppelin-0.9.0-preview2-bin-all.tgz
ENV IPYTHONDIR /home/$NB_USER/.ipython jupyter lab --watch
EXPOSE 8888
EXPOSE 8787
EXPOSE 4040
EXPOSE 8080
ENTRYPOINT 
CMD [ "notebook" ]
