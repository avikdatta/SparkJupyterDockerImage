#!/usr/bin/env bash
case "$1" in
notebook)
  source ~/.bashrc
  export HAIL_HOME=$(pip show hail | grep Location | awk -F' ' '{print $2 "/hail"}')
  export PYTHONPATH=${PYTHONPATH}:$HAIL_HOME/python
  export PATH=$PATH:$SPARK_HOME/bin::$HAIL_HOME/bin/
  export JAR_PATH=$HAIL_HOME/hail-all-spark.jar
  export PYSPARK_SUBMIT_ARGS="--conf spark.driver.extraClassPath=${JAR_PATH} --conf spark.executor.extraClassPath=${JAR_PATH} --conf spark.serializer=org.apache.spark.serializer.KryoSerializer  --conf spark.kryo.registrator=is.hail.kryo.HailKryoRegistrator pyspark-shell"

  exec jupyter lab \
  --ip=0.0.0.0 \
  --port=8887 \
  --no-browser \
  --NotebookApp.iopub_data_rate_limit=100000000
  ;;
*)
exec "$@"
    ;;
esac
