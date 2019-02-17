#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

# $1 = "GROUP" or "INSTANCE"
# $2 = name of group or instance
# $3 = target state of transition ("MASTER", "BACKUP", "FAULT")

# Create file with keepalived server state

echo $3 > /var/run/keepalive.$1.$2.state
