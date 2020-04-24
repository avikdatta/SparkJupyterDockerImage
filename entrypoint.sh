#!/usr/bin/env bash
case "$1" in
notebook)
  . /home/vmuser/miniconda3/etc/profile.d/conda.sh
  conda activate notebook-env
  SPARK_HOME=$(pip show pyspark | grep Location | awk -F' ' '{print $2 "/pyspark" }')
  export SPARK_HOME=$SPARK_HOME
  export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9-src.zip
  export SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info"
  export PATH=$PATH:$SPARK_HOME/bin
  HAIL_HOME=$(pip show hail | grep Location | awk -F' ' '{print $2 "/hail"}')
  export HAIL_HOME=$HAIL_HOME
  export PYTHONPATH=${PYTHONPATH}:$HAIL_HOME/python
  export PATH=$PATH:$SPARK_HOME/bin::$HAIL_HOME/bin/
  export JAR_PATH=$HAIL_HOME/hail-all-spark.jar
  export PYSPARK_SUBMIT_ARGS="--conf spark.driver.extraClassPath=${JAR_PATH} --conf spark.executor.extraClassPath=${JAR_PATH} --conf spark.serializer=org.apache.spark.serializer.KryoSerializer  --conf spark.kryo.registrator=is.hail.kryo.HailKryoRegistrator pyspark-shell"

  jupyter lab \
    --ip=0.0.0.0 \
    --port=8887 \
    --no-browser \
    --NotebookApp.iopub_data_rate_limit=100000000
    
  ;;
*)
exec "$@"
    ;;
esac
