#!/bin/bash
###/etc/keepalived/scripts/redis_check.sh

ALIVE=`/usr/local/redis/bin/redis-cli -h localhost -h 6379 PING`
LOGFILE="/var/log/keepalived/keepalived-redis-check.log"
pid=$$

for ((i=0; i<2; i++))
do
    if [ "$ALIVE" == "PONG" ]; then
        echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[check] Success: PING $ALIVE " >> $LOGFILE 2>&1
        exit 0
    else
        echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[check] Failed: PING $ALIVE " >> $LOGFILE 2>&1
        sleep 1
    fi
done
exit 1

