#!/bin/bash
# Check web healthcheck status (200 or NOT)

HOSTADDRESS=$(ifconfig eth0 | grep -w "inet" | awk '{print $2}')
curl=$(curl -LI http://$HOSTADDRESS -o /dev/null -w '%{http_code}\n' -s)

if [ $curl != 200 ]
then
    exit 1
else
    exit 0
fi
