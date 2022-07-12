#balancer
nohup hdfs balancer -D "dfs.balancer.movedWinWidth=300000000" -D "dfs.datanode.balance.bandwidthPerSec=2000m" -threshold 1 > my-hadoop-balancer-v2021u1109.log 2>&1 &
