#!/bin/bash
###/etc/keepalived/scripts/redis_backup.sh

REDISCLI="/opt/redis/bin/redis-cli"
LOGFILE="/var/log/keepalived/keepalived-redis-state.log"
pid=$$
host=$1
port=$2

echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[master] Being slave state..." >> $LOGFILE 2>&1
echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[master] wait 10 sec for data sync from old master" >> $LOGFILE 2>&1
sleep 10
echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[master] data rsync from old mater ok..." >> $LOGFILE 2>&1
echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[slaver] Run 'SLAVEOF $host $port'" >> $LOGFILE 2>&1
$REDISCLI SLAVEOF $host $port >> $LOGFILE  2>&1
echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[slaver] slave connect to $host ok..." >> $LOGFILE 2>&1

