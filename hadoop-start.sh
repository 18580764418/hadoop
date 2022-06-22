#!/bin/bash

cd /opt/hadoop && sbin/start-dfs.sh && mapred --daemon start historyserver
sleep 5 && hdfs dfsadmin -safemode leave &&sbin/start-yarn.sh
cd /usr/local/spark/ && sbin/start-all.sh
cd ~ 
nohup hive --service metastore -p 9083 >> /dev/null 2>&1 &
nohup  hive --service hiveserver2 >> /dev/null 2>&1 &
