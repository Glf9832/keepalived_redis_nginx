#!/bin/bash
# Check web healthcheck status (200 or NOT)


curl=$(curl -LI http://localhost -o /dev/null -w '%{http_code}\n' -s)

if [ $curl != 200 ]
then
    exit 1
else
    exit 0
fi
