# hadoop集群节点环境准备：
```
1、网速测试工具iperf3,需关闭防火墙
  服务端：iperf3 -s -i 1 -p 1314
  客户端：iperf3 -c host -i 1 -t 60 -p 1314
2、配置hostname
3、配置/etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

10.10.1.22      slave2
10.10.1.23      slave1
10.10.1.25      master
4、禁用SELinux
临时修改：setenforce 0 （回显有效，无回显无效）
setenforce: SELinux is disabled
永久生效：vim /etc/selinux/config （重启生效）
验证：sestatus -v
SELinux status:                 disabled
5、关闭防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl status firewalld.service (验证)
#6、设置SWAP
#vim /etc/sysctl.conf
#vm.swappiness = 10
#验证：
#[root@ip-172-31-6-148~]# sysctl -p
#…
#kernel.msgmnb= 65536
#kernel.msgmax= 65536
#kernel.shmmax= 68719476736
#kernel.shmall= 4294967296
#vm.swappiness= 10
7、关闭透明大页面
echo never > /sys/kernel/mm/transparent_hugepage/defrag 
echo never > /sys/kernel/mm/transparent_hugepage/enabled
永久生效：
在集群所有节点vim /etc/rc.d/rc.local脚本中增加如下代码，使其永久生效
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
   echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
   echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
赋予rc.local脚本可执行权限
[root@ip-172-31-6-148rc.d]# chmod +x /etc/rc.d/rc.local
8、配置时钟同步
8.1、server 端配置vim /etc/ntp.conf:
# 允许内网其他机器同步时间（10.211.55.0 修改为自己的ip掩码）
restrict 10.10.1.0 mask 255.255.255.0 nomodify notrap
 
# Use public servers from the pool.ntp.org project.
# 中国这边最活跃的时间服务器 : [http://www.pool.ntp.org/zone/cn](http://www.pool.ntp.org/zone/cn)
server 210.72.145.44 perfer   # 中国国家受时中心
server 202.112.10.36             # 1.cn.pool.ntp.org
server 59.124.196.83             # 0.asia.pool.ntp.org
   
# allow update time by the upper server 
# 允许上层时间服务器主动修改本机时间
restrict 210.72.145.44 nomodify notrap noquery
restrict 202.112.10.36 nomodify notrap noquery
restrict 59.124.196.83 nomodify notrap noquery
 
# 外部时间服务器不可用时，以本地时间作为时间服务
server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10
8.2、client端配置 vim /etc/ntp.conf ：
# 让NTP Server为内网的ntp服务器（ 10.211.55.10修改为master节点ip）
server 10.10.1.25
fudge 10.10.1.25 stratum 5
 
# 不允许来自公网上ipv4和ipv6客户端的访问
restrict -4 default kod notrap nomodify nopeer noquery 
restrict -6 default kod notrap nomodify nopeer noquery
 
# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1
8.3 client端定时任务 crontab -e 或 /var/spool/cron/root
0 0 * * * ntpdate -u master
```


