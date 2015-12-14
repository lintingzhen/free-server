#!/usr/bin/env bash

source /opt/.global-utils.sh

ln -s ${utilDir}/createuser.sh ${freeServerRoot}/createuser

echoS "Write to crontab for auto restart"

# smart service watcher for every 2 minutes
catchError=$(${freeServerRoot}/cron-shadowsocks-forever-process-running-generate-cron.d  2>&1 >> ${loggerStdoutFile})
exitOnError "${catchError}"

catchError=$(${freeServerRoot}/cron-ipsec-forever-process-running-generate-cron.d 2>&1 >> ${loggerStdoutFile})
exitOnError "${catchError}"

#${freeServerRoot}/cron-spdy-forever-process-running-generate-cron.d
catchError=$(${freeServerRoot}/cron-spdy-nghttpx-squid-forever-process-running-generate-cron.d 2>&1 >> ${loggerStdoutFile})
exitOnError "${catchError}"

# restart cron service
catchError=$(service cron restart 2>&1 >> ${loggerStdoutFile})
exitOnError "${catchError}"

echoS "Restart Shadowsocks/SPDY/IPSec"

catchError=$(${freeServerRoot}/restart-ipsec  2>&1 >> ${loggerStdoutFile})
exitOnError "${catchError}"

catchError=$(${freeServerRoot}/restart-shadowsocks 2>&1 >> ${loggerStdoutFile})
exitOnError "${catchError}"

#${freeServerRoot}/restart-spdy
catchError=$(${freeServerRoot}/restart-spdy-nghttpx-squid 2>&1 >> ${loggerStdoutFile})
exitOnError "${catchError}"

echoS "Create a simple website for testing purpose."

catchError=$(npm install -g forever >> ${loggerStdoutFile})
exitOnError "${catchError}"

catchError=$(${utilDir}/restart-misc.sh >> ${loggerStdoutFile})
exitOnError "${catchError}"

