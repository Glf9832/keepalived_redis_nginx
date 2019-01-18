#!/bin/bash
###/etc/keepalived/scripts/redis_fault.sh

LOGFILE="/var/log/keepalived/keepalived-redis-state.log"
pid=$$

echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[fault]" >> $LOGFILE 2>&1

