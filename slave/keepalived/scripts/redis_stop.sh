#!/bin/bash
###/etc/keepalived/scripts/redis_stop.sh

LOGFILE="/var/log/keepalived/keepalived-redis-state.log"
pid=$$

echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[stop]" >> $LOGFILE 2>&1




