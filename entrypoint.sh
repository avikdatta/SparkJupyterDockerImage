#!/usr/bin/env bash
case "$1" in
notebook)
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
