#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

# $1 = "GROUP" or "INSTANCE"
# $2 = name of group or instance
# $3 = target state of transition ("MASTER", "BACKUP", "FAULT")

case $STATE in
        "MASTER") systemctl start nginx
                  echo -e "state: $3 \naction: start nginx" > /var/run/keepalive.$1.$2.state
                  exit 0
                  ;;
        "BACKUP") systemctl stop nginx
                  echo -e "state: $3 \naction: stop nginx" > /var/run/keepalive.$1.$2.state
                  exit 0
                  ;;
        "FAULT")  systemctl stop nginx
                  echo -e "state: $3 \naction: stop nginx" > /var/run/keepalive.$1.$2.state
                  exit 0
                  ;;
        *)        echo -e "state: $3 \naction: none" > /var/run/keepalive.$1.$2.state
                  exit 1
                  ;;
esac
