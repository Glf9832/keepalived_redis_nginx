#!/bin/bash

ALIVE=`/usr/local/redis/bin/redis-cli PING`
LOGFILE="/var/log/keepalived/keepalived-redis-check.log"
pid=$$

HOSTADDRESS=$(ifconfig eth0 | grep -w "inet" | awk '{print $2}')
curl_nginx=$(curl -LI http://$HOSTADDRESS -o /dev/null -w '%{http_code}\n' -s)

log() {
    local msg=$1
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') | $pid | $msg" >> $LOGFILE 2>&1
}

for ((i=0; i<2; i++))
do
    if [ "$ALIVE" == "PONG" ] && [ $curl_nginx == 200 ]; then
        exit 0
    else
        log "[REDIS] Redis PING state: $ALIVE"
        log "[NGINX] Nginx curl code: $curl_nginx"
        sleep 1
    fi
done
exit 1
