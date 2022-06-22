#!/bin/bash

cd /opt/hadoop && sbin/stop-yarn.sh  && mapred --daemon stop historyserver && sbin/stop-dfs.sh
cd /usr/local/spark/ && sbin/stop-all.sh
cd ~
pgrep -f hive | xargs kill
