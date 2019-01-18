#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

case $STATE in
        "MASTER") systemctl start nginx
                  exit 0
                  ;;
        "BACKUP") systemctl stop nginx
                  exit 0
                  ;;
        "FAULT")  systemctl stop nginx
                  exit 0
                  ;;
        *)        echo "unknown state"
                  exit 1
                  ;;
esac