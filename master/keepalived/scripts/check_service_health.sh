#!/usr/bin/env bash

ALIVE=`/usr/local/redis/bin/redis-cli -h localhost -p 6379 PING`
LOGFILE="/var/log/keepalived/keepalived-check-service.log"
pid=$$

HOSTADDRESS=$(ifconfig eth0 | grep -w "inet" | awk '{print $2}')
curl_nginx=$(curl -LI http://$HOSTADDRESS -o /dev/null -w '%{http_code}\n' -s)
curl_uwsgi=$(curl -LI http://localhost:8000 -o /dev/null -w '%{http_code}\n' -s)

if [ $curl_nginx != 200 ]; then
    echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[check] Failed: $curl_nginx " >> $LOGFILE 2>&1
    exit 1
fi

if [ $curl_uwsgi != 200 ]; then
    echo "`date +'%Y-%m-%d %H:%M:%S'`|$pid|state:[check] Failed: $curl_uwsgi " >> $LOGFILE 2>&1
    exit 1
fi

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
