#!/bin/bash


export SHELL=/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

if [[ $UID -ne 0 ]]; then
    echo "$0 must be run as root"
    exit 1
fi


export currentDate=$(date +"%m_%d_%Y")

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export globalUtilFile=$0

export bashrc=~/.bashrc

export baseUrl=https://raw.githubusercontent.com/lanshunfang/free-server/master/

export freeServerInstallationFolderName=free-server
# the top install folder
export freeServerRoot=/opt/${freeServerInstallationFolderName}/

# utility folder
export utilDir=${freeServerRoot}/util

# for configration samples
export configDir=${freeServerRoot}/config
export configDirBackup=/opt/free-server-config-bak
export configDirBackupDate=/opt/free-server-config-bak-$currentDate

export freeServerGlobalEnv=${configDir}/envrc

if [[ -f ${freeServerGlobalEnv} ]]; then
    source ${freeServerGlobalEnv}
fi

# let's encrypt
export letsEncryptCertPath=/etc/letsencrypt/live/$freeServerName/fullchain.pem
export letsEncryptKeyPath=/etc/letsencrypt/live/$freeServerName/privkey.pem
export letsencryptInstallationFolder=${freeServerRoot}/letsencrypt
export letsencryptAutoPath=${letsencryptInstallationFolder}/letsencrypt-auto

# temporary folder for installation
export freeServerRootTmp=${freeServerRoot}/tmp
export freeServerRootMisc=${freeServerRoot}misc

export baseUrlUtils=${baseUrl}/utils
export baseUrlBin=${baseUrl}/bin
export baseUrlSetup=${baseUrl}/setup-tools
export baseUrlConfigSample=${baseUrl}/config-sample
export baseUrlMisc=${baseUrl}/misc

export oriConfigShadowsocksDir="/etc/shadowsocks-libev/"
export oriConfigShadowsocks="${oriConfigShadowsocksDir}/config.json"

export SPDYNgHttp2DownloadLink="https://github.com/nghttp2/nghttp2/releases/download/v1.9.1/nghttp2-1.9.1.tar.gz"
export SPDYNgHttp2FolderName="nghttp2-1.9.1"
export SPDYNgHttp2TarGzName="${SPDYNgHttp2FolderName}.tar.gz"
export SPDYSpdyLayDownloadLink="https://github.com/tatsuhiro-t/spdylay/releases/download/v1.3.2/spdylay-1.3.2.tar.gz"
export SPDYSpdyLayFolderName="spdylay-1.3.2"
export SPDYSpdyLayTarGzName="${SPDYSpdyLayFolderName}.tar.gz"
export SPDYConfig="${configDir}/SPDY.conf"
export SPDYSquidConfig="${configDir}/squid.conf"
export SPDYSquidCacheDir="/var/spool/squid3"
export SPDYSquidPassWdFile="${configDir}/squid-auth-passwd"

# make SPDYSquidAuthSubProcessAmount bigger, make squid basic auth faster, but may be more unstable indeed
export SPDYSquidAuthSubProcessAmount=4

export SPDYForwardBackendSquidHost="127.0.0.1"
export SPDYForwardBackendSquidPort=3128
export SPDYFrontendListenHost="0.0.0.0"

# make SPDYNgHttpXCPUWorkerAmount bigger, make nghttpx faster, but may be unstable if your VPS is not high-end enough
export SPDYNgHttpXCPUWorkerAmount=2

export SPDYNgHttpXConcurrentStreamAmount=600

export ipsecSecFile=${configDir}/ipsec.secrets
export ipsecSecFileInConfigDirBackup=${configDirBackup}/ipsec.secrets
export ipsecSecFileOriginal=/usr/local/etc/ipsec.secrets
export ipsecSecFileOriginalDir=/usr/local/etc/
export ipsecSecFileBak=/usr/local/etc/ipsec.secrets.bak.free-server
#export ipsecSecFileBakQuericy=/usr/local/etc/ipsec.secrets.bak.quericy
export ipsecSecPskSecretDefault=freeserver
export ipsecStrongManVersion=strongswan-5.3.3
export ipsecStrongManVersionTarGz=${ipsecStrongManVersion}.tar.gz
## ipsecStrongManOldVersion should be added if you want to update the ${ipsecStrongManVersion}, so that the script can clean the old files
export ipsecStrongManOldVersion=strongswan-5.2.1
export ipsecStrongManOldVersionTarGz=${ipsecStrongManOldVersion}.tar.gz

export ocservPasswd=${configDir}/ocserv.passwd
export ocservConfig="${configDir}/ocserv.conf"

export ocservPortMin=3000
export ocservPortMax=3010


export clusterDefFilePath="${configDir}/cluster-def.txt"
export clusterDeploySSHMutualAuthAccept="${freeServerRoot}/cluster-deploy-ssh-mutual-auth-accept"

export loggerStdoutFolder=${freeServerRoot}/log
export loggerStdoutFile=${loggerStdoutFolder}/stdout.log
export loggerStderrFile=${loggerStdoutFolder}/stderr.log
export loggerRuntimeInfoFile=${loggerStdoutFolder}/runtime_info.log
export loggerRuntimeErrFile=${loggerStdoutFolder}/runtime_error.log

enforceInstallOnUbuntu(){
	isUbuntu=`cat /etc/issue | grep "Ubuntu"`

	if [[ -z ${isUbuntu} ]]; then
	  echoS "You could only run the script in Ubuntu"
	  exit 1
	fi

}
export -f enforceInstallOnUbuntu

enforceInstallOnUbuntu

isUbuntu14(){
	isUbuntu=`cat /etc/issue | grep "Ubuntu 14."`

	if [[ ! -z ${isUbuntu} ]]; then
	  echo "YES"
	fi

}
export -f isUbuntu14

enforceInstallOnUbuntu

warnNoEnterReturnKey() {
  echoS "\x1b[31m Do NOT press any Enter/Return key while script is compiling / downloading \x1b[0m if haven't been asked. Or, it may fail." "stderr"
}

randomString()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}
export -f randomString

echoS(){
  echo "***********++++++++++++++++++++++++++++++++++++++++++++++++++***********"
  echo "##"
  if [[ "$2" == "stderr" ]]; then
    >&2 echo -e "## \x1b[31m $1 \x1b[0m"
  else
    echo -e "## \x1b[34m $1 \x1b[0m"
  fi
  echo "##"

  echo "***********++++++++++++++++++++++++++++++++++++++++++++++++++***********"

}
export -f echoS

echoErr(){
  >&2 echo -e "\x1b[31m$@\x1b[0m"
}
export -f echoErr

echoSExit(){
  echoS "$1"
  sleep 1
  exit 0
}
export -f echoSExit

exitOnError(){
  if [[ ! -z $1 ]]; then
    echoS "Error message detected, content is below"
    echo "$1"
    if [[ -f ${loggerStderrFile} ]]; then

        echo "Redirect error message to ${loggerStderrFile}:"
        echo "$1" >> ${loggerStderrFile}
        sleep 1
        echo ">>>>>>>>>>>>>>>>>>"
        echo ">>>>>>>>>>>>>>>>>>"
        echo "Cat ${loggerStderrFile}:"
        cat ${loggerStderrFile}
        echo "<<<<<<<<<<<<<<<<<<"
        echo "<<<<<<<<<<<<<<<<<<"

    else
        echo "${loggerStderrFile} is not existed. Skipping saving Error Log."
    fi

    sleep 2
    exit 1
  fi
}
export -f exitOnError

checkPortClosed(){
    sleep 1
    port=$1
    nc -z localhost $port
}
export -f checkPortClosed

waitUntilPortOpen() {
    port=$1
    maxWait=$2
    currentSecond=0
    checkPortClosed ${port}
    isPortClosed=$?

    while (( $currentSecond < $maxWait ))  && [[ $isPortClosed == 1 ]]; do
        sleep 1

        checkPortClosed ${port}

        isPortClosed=$?

        (( currentSecond++ ))
    done

    if [[ $isPortClosed == 1 ]]; then
        echoErr "Error: Port $port is still closed on max timeout $maxWait seconds."
        return 1
    else
        return 0
    fi
}
export -f waitUntilPortOpen

runCommandIfPortClosed(){
    port=$1
    commandToRun=$2

    checkPortClosed ${port}
    isPortClosed=$?

    if [[ $isPortClosed == 0 ]]; then
        return 0
    else
        eval $commandToRun
    fi

    maxTry=2
    currentTry=0

    while (( $currentTry < $maxTry ))  && [[ $isPortClosed == 1 ]]; do

            waitUntilPortOpen ${port} 3

            isPortClosed=$?

            if [[ $isPortClosed == 0 ]]; then
                return 0
            else
                echo ""
                #eval $commandToRun
            fi

            (( currentTry++ ))

    done
}
export -f runCommandIfPortClosed


killProcessesByPattern(){
  echo -e "\nThe process(es) below would be killed"
  ps aux | gawk '/'$1'/ {print}' | cut -d" " -f 24-
  ps aux | gawk '/'$1'/ {print $2}' | xargs kill -9
  echo -e "\n\n"

}
export -f killProcessesByPattern

removeWhiteSpace(){
  echo $(echo "$1" | gawk '{gsub(/ /, "", $0); print}')
}
export -f removeWhiteSpace

#####
# get interfact IP
#####
getIp(){
  /sbin/ifconfig|grep 'inet addr'|cut -d':' -f2|awk '!/127/ {print $1}'
}
export -f getIp

#####
# download a file to folder
#
# @param String $1 is the url of file to downlaod
# @param String $2 is the folder to store
# @example downloadFileToFolder http://www.xiaofang.me/some.zip ~/free-server
#####
downloadFileToFolder(){
  echo "[$FUNCNAME] Prepare to download file $1 into Folder $2"

  if [ ! -d "$2" ]; then
    echoS "[$FUNCNAME] Folder $2 is not existed. Exit" "stderr"
    exit 1
  fi
  if [ -z $1 ]; then
    echoS "[$FUNCNAME] Url must be provided. Exit" "stderr"
    exit 1
  fi
  wget --no-cache -q --directory-prefix="$2" "$1"
}
export -f downloadFileToFolder


#####
#
# @param String $1 is the file to operate
# @param RegExp String $2 is searching pattern in regexp
# @param RegExp String $3 is replacement
#####
replaceStringInFile(){

  if [ "x$1" = "x-h" -o "x$1" = "x--help" ]
  then
    echo "$FUNCNAME FileName SearchingPattern Replacement "
    exit 0
  fi

  # all the arguments should be given
  if [[ -z $1 || -z $2 || -z $3 ]];then
    echo "[$FUNCNAME] You should provide all 3 arguments to invoke $FUNCNAME"
    exit 1
  fi

  if [[ ! -f $1 ]]; then
    echo "[$FUNCNAME] File $1 is not existed"
    exit 1
  fi

  # find and remove the line matched to the pattern

  sed -i "s#$2#$3#g" $1

}
export -f replaceStringInFile


#####
#
# @param String $1 is the file to operate
# @param RegExp String $2 is searching pattern for sed
#####
removeLineInFile(){

  if [ "x$1" = "x-h" -o "x$1" = "x--help" ]
  then
    echo "$FUNCNAME FileName SearchingPattern"
    exit 0
  fi

  # all the arguments should be given
  if [[ -z $1 ]] || [[ -z $2 ]];then
    echo "You should provide all 2 arguments to invoke $$FUNCNAME"
    exit 1
  fi

  if [[ ! -f $1 ]]; then
    echo "File $1 is not existed"
    exit 1
  fi

  # find and remove the line matched to the pattern

  sed -i "/$2/d" $1

}
export -f removeLineInFile

# usage:   removeLineByRegPattAndInsert /etc/sysctl.conf "fs\.file-max" "fs.file-max = 51200"
removeLineByRegPattAndInsert() {
  file=$1
  regexpForSed=$2
  linkToAppend=$3
  removeLineInFile "${file}" "${regexpForSed}"
  echo "${linkToAppend}" >> "${file}"

}
export -f removeLineByRegPattAndInsert

#####
# Add date to String
#
# @param String $1 is the origin String
# @example file$(appendDateToString).bak
#####
appendDateToString(){
  echo "-$currentDate"
}
export -f appendDateToString


#####
# Get User Input
#
# @param String $1 is the prompt
# @param String $2 file if the input must be a file, non-empty if the input must not empty
# @param Number $3 Max try times

# @example input=$(getUserInput "Provide File" file 3)
#####
getUserInput(){

  promptMsg=$1
  inputValidator=$2
  maxtry=$3

  userinput=''

  if [[ -z ${promptMsg} ]]; then
    echoS '@example input=$(getUserInput "Provide File" file 3)'
    exit 0
  fi

  if [[ -z ${maxtry} ]]; then
    maxtry=3
  fi

  while [ ${maxtry} -gt 0 ]; do

    sleep 1

    read -p "$(echo -e ${maxtry} attempt\(s\) left, ${promptMsg}) \$: " userinput
    userinput=$(removeWhiteSpace "${userinput}")

    if [[ "${inputValidator}" == "file" ]]; then
      if [[ ! -f "${userinput}"  ]]; then
        echoErr "The file ${userinput} you input is empty or not a file."
        userinput=''
      else
        break
      fi
    fi

    if [[ "${inputValidator}" == "non-empty" ]]; then
      if [[  -z "${userinput}" ]]; then
        echo "\x1b[0m The input should not be empty.\x1b[0m"
      else
        break
      fi
    fi


    ((maxtry--))

    if [[ -z ${inputValidator} ]]; then
        break
    fi

  done

  echo ${userinput}

}
export -f getUserInput


#####
# Import MySQL db sql backup tar.gz to database
#
# @param String $1 is the backup folder to list
# @param String $2 is the database name
# @example importSqlTarToMySQL Folder
#####
importSqlTarToMySQL(){

  dbFolder=$1

  if [[ ! -d ${dbFolder} ]]; then
    echoS "Folder ${dbFolder} is not existed" "stderr"
    echoS "@example importSqlTarToMySQL ~/backup/"
    return 0
  fi

  echoS "Here is all the files found within folder ${dbFolder}\n"
  cd ${dbFolder}
  ls . | grep .gz

  echo -e "\n\n"

  dbTarGz=$(getUserInput "Enter a *.tar.gz to import (Copy & Paste):  " file)
  echoS "Selected tar.gz is ${dbTarGz}"

  if [[ ! -f ${dbTarGz} || -z $(echo ${dbTarGz} | grep .gz) ]]; then
    echoS "${dbTarGz} is not a valid *.tar.gz file"
    exit 0
  fi

  sleep 1

  # provide the db name to create
  dbName=$(getUserInput "the database name to import to:  " non-empty)
  echoS "dbName is ${dbName}"
  if [[  -z ${dbName} ]]; then
    exit 0
  fi

  sleep 1


  # provide the new user name
  dbNewUser=$(getUserInput "The owner user name of database ${dbName} (Non-root):  " non-empty)
  echoS "dbNewUser is ${dbNewUser}"
  if [[  -z ${dbNewUser} ]]; then
    exit 0
  fi

  sleep 1


  # provide password for the new user
  dbPass=$(getUserInput "input password for user ${dbNewUser} of Db ${dbName} (Non-root):  " non-empty)
  echoS "dbPass is ${dbPass}"
  if [[  -z ${dbPass} ]]; then
    exit 0
  fi

  sleep 1


  # create user and grant
  echoS "Create new Db ${dbName} with Db user ${dbNewUser}. \n\nProvide MySQL root password:"

  sql="CREATE DATABASE IF NOT EXISTS ${dbName} ; \
  GRANT ALL PRIVILEGES ON ${dbName}.* To '${dbNewUser}'@'localhost' IDENTIFIED BY '${dbPass}';\
  FLUSH PRIVILEGES;"
  mysql -uroot -p -e "$sql"

  echoS "Exact ${dbTarGz}."
  rm -rf ~/__to_import > /dev/null
  mkdir -p ~/__to_import  > /dev/null
  tar zxf ${dbTarGz} -C ~/__to_import
  cd ~/__to_import  > /dev/null

  sleep 1

  dbSql=$(ls . | gawk '/\.sql/ {print}')

  echoS "Importing ${dbSql} to database ${dbName}.\n\n Provide MySQL root password again:"
  mysql -uroot -p ${dbName} < ${dbSql}
  rm -rf ~/__to_import
}
export -f importSqlTarToMySQL


optimizeLinuxForShadowsocks(){

  removeLineByRegPattAndInsert /etc/security/limits.conf "soft nofile 51200" "* soft nofile 51200"
  removeLineByRegPattAndInsert /etc/security/limits.conf "hard nofile 51200" "* hard nofile 51200"

  ulimit -n 51200

  removeLineByRegPattAndInsert /etc/sysctl.conf "fs\.file-max" "fs.file-max = 51200"
  removeLineByRegPattAndInsert /etc/sysctl.conf "rmem_max" "net.core.rmem_max = 67108864"
  removeLineByRegPattAndInsert /etc/sysctl.conf "wmem_max" "net.core.wmem_max = 67108864"
  removeLineByRegPattAndInsert /etc/sysctl.conf "netdev_max_backlog" "net.core.netdev_max_backlog = 250000"
  removeLineByRegPattAndInsert /etc/sysctl.conf "somaxconn" "net.core.somaxconn = 4096"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_syncookies" "net.ipv4.tcp_syncookies = 1"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_tw_reuse" "net.ipv4.tcp_tw_reuse = 1"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_tw_recycle" "net.ipv4.tcp_tw_recycle = 0"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_fin_timeout" "net.ipv4.tcp_fin_timeout = 30"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_keepalive_time" "net.ipv4.tcp_keepalive_time = 1200"
  removeLineByRegPattAndInsert /etc/sysctl.conf "ip_local_port_range" "net.ipv4.ip_local_port_range = 10000 65000"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_max_syn_backlog"  "net.ipv4.tcp_max_syn_backlog = 8192"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_max_tw_buckets"  "net.ipv4.tcp_max_tw_buckets = 5000"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_fastopen"  "net.ipv4.tcp_fastopen = 3"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_rmem"  "net.ipv4.tcp_rmem = 4096 87380 67108864"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_wmem"  "net.ipv4.tcp_wmem = 4096 65536 67108864"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_mtu_probing"  "net.ipv4.tcp_mtu_probing = 1"
  removeLineByRegPattAndInsert /etc/sysctl.conf "tcp_congestion_control"  "net.ipv4.tcp_congestion_control = hybla"

  sysctl -p
}

export -f optimizeLinuxForShadowsocks


# get current server name
setServerName() {

  serverName=$(getUserInput "Input \x1b[46m Server Domain \x1b[0m (e.g. vpn.xiaofang.me): " non-empty 3)

  if [[ -z ${serverName} ]]; then

    echoErr "Sever Name should not be empty"

  else

    echo "export freeServerName=${serverName}" >> ${freeServerGlobalEnv}

  fi


}
export -f setServerName

# get current user email
setEmail() {

  email=$(getUserInput "Input \x1b[46m Your Email \x1b[0m (e.g. paul_lan@gmail.com): " non-empty 3)

  if [[ -z ${email} ]]; then

    echoErr "User Email should not be empty"

  else

    echo "export freeServerUserEmail=${email}" >> ${freeServerGlobalEnv}

  fi


}
export -f setEmail

# get current user email
prepareLetEncryptEnv() {

    forever stop /opt/free-server/misc/testing-web.js
    service nginx stop

}
export -f prepareLetEncryptEnv

# get current user email
afterLetEncryptEnv() {

    forever start /opt/free-server/misc/testing-web.js
    service nginx restart

}
export -f afterLetEncryptEnv


enableIptableToConnectInternet(){

    ipt=/sbin/iptables

    sysctl --quiet -w net.ipv4.ip_forward=1

    $ipt -F FORWARD
    $ipt -P FORWARD DROP
    $ipt -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    $ipt -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
    $ipt -A FORWARD -i vpns+ -o eth0 -j ACCEPT
    $ipt -A FORWARD -i vpns+ -o vpns+ -j ACCEPT

    $ipt -t nat -F POSTROUTING
    $ipt -t nat -A POSTROUTING -o eth0 -j MASQUERADE

}
export -f enableIptableToConnectInternet

updateOcservConf() {

    if [[ ! -f ${ocservConfig} ]]; then
        echoS "Ocserv config file (${ocservConfig}) is not detected. This you may not install it correctly. Exit." "stderr"
        exit 1
    fi

    echoS "Create multiple instance for better connect"
    for (( port=$ocservPortMin; port<=$ocservPortMax; port++ ));do
        duplicateConfByPort ${port}
    done

    duplicateConfByPort 443

}
export -f updateOcservConf

updateRouteForOcservConf() {
    mv ${configDir}/ocserv.conf ${configDir}/ocserv.conf.bak
    downloadFileToFolder ${baseUrlConfigSample}/ocserv.conf ${configDir}
    if [[ $? == 1 ]]; then
        echoS "Download failed: ${baseUrlConfigSample}/ocserv.conf"
        mv ${configDir}/ocserv.conf.bak ${configDir}/ocserv.conf
        return 1
    fi
    rm ${configDir}/ocserv.conf.bak
    updateOcservConf
    ${freeServerRoot}/restart-ocserv

}
export -f updateRouteForOcservConf


duplicateConfByPort(){
    port=$1

    newConfName=${ocservConfig}.${port}
    rm ${newConfName}

    cp ${ocservConfig} ${newConfName}

    replaceStringInFile "${newConfName}" __SSL_KEY_FREE_SERVER__ "${letsEncryptKeyPath}"
    replaceStringInFile "${newConfName}" __SSL_CERT_FREE_SERVER__ "${letsEncryptCertPath}"
    replaceStringInFile "${newConfName}" __TCP_PORT__ "${port}"
    replaceStringInFile "${newConfName}" __UDP_PORT__ "${port}"
}

export -f duplicateConfByPort


