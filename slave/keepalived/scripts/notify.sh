#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

# $1 = "GROUP" or "INSTANCE"
# $2 = name of group or instance
# $3 = target state of transition ("MASTER", "BACKUP", "FAULT")

pid=$$

vip=10.211.55.10
backup_ip=10.211.55.5
redis_port=6379

REDISCLI="/usr/local/redis/bin/redis-cli -h localhost -p $redis_port"
LOGFILE="/var/log/keepalived/keepalived-state.log"

log() {
    local msg=$1
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') | $pid | $msg" >> $LOGFILE 2>&1
}

redis_to_slave() {
    # master host
    local host=$1
    # master redis port
    local port=$2
    # sync time
    local sleep_time=10

    log "[REDIS] Redis is prepare to enter to SLAVE model"
    log "[REDIS] Running 'SLAVEOF $host $port'"
    $REDISCLI SLAVEOF $host $port

    # echo $(log "Redis info replication : ")
    # $REDISCLI info replication >> $LOGFILE  2>&1
    local redis_role=$($REDISCLI info replication |grep role |awk -F: '{print $2}')
    local redis_master_status=$($REDISCLI info replication |grep master_link_status |awk -F: '{print $2}')
    log "[REDIS] Redis current role: $redis_role"
    log "[REDIS] Redis master status: $redis_master_status"

    log "[REDIS] Redis data rsync to local from $host"

    log "[REDIS] Wait $sleep_time sec for data sync from $host"
    sleep $sleep_time
    log "[REDIS] Redis data rsync from $host ok"
}

redis_to_master() {
    log "[REDIS] Redis is prepare to enter to MASTER model"
    log "[REDIS] Running SLAVEOF NO ONE"
    $REDISCLI SLAVEOF NO ONE

    local redis_role=$($REDISCLI info replication |grep role |awk -F: '{print $2}')

    log "[REDIS] Redis current role: $redis_role"
    log "[REDIS] Waiting other slave connect"
}

nginx_start() {
    log "[NGINX] Running systemctl start nginx"
    systemctl start nginx
    log "[NGINX] Nginx started"
}

nginx_close() {
    log "[NGINX] Running systemctl stop nginx"
    systemctl stop nginx
    log "[NGINX] Nginx stopped"
}

case $STATE in
        "MASTER")
            log "[KEEPALIVED] Keepalived enter MASTER model"

            redis_to_slave $vip $redis_port
            redis_to_master
            nginx_start

            log "[KEEPALIVED] Keepalived_state: $STATE"

            exit 0;;
        "BACKUP")
            log "[KEEPALIVED] Keepalived enter BACKUP model"

            redis_to_slave $backup_ip $redis_port

            nginx_start
            log "[KEEPALIVED] Keepalived_state: $STATE"

            exit 0;;
        "FAULT")
            log "[KEEPALIVED] Keepalived enter FAULT model"

            nginx_close
            log "[KEEPALIVED] Keepalived_state: $STATE"

            exit 0;;
        *)
            log "[KEEPALIVED] Keepalived_state: $STATE"

            exit 1;;
esac
