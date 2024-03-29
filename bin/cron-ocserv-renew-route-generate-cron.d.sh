#!/bin/bash

source /opt/.global-utils.sh

## file to write to cron.d
file="/etc/cron.d/free-server-renew-route-ocserv"

## process restart daily command
restartCommand="/bin/bash ${freeServerRoot}/renew-route-ocserv"

## renew route every day
echo "17 21 * * * root ${restartCommand}" >> ${file}

echo "Done, cat ${file}"
cat ${file}

## restart crond
service cron restart
echo "Crontab restart, new PID: $(pgrep cron)"