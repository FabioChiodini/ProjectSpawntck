#!/bin/bash
#Loads variables
#Must use Cloud1 for accounts (any way to change this?)
#Some variables are modified later by fetching data from etcd
. /home/$USER/Cloud1
echo "loaded Config file"


#gets data on setup from etcd

#gets data from previous run

#HoneypotPortK=`(curl http://127.0.0.1:4001/v2/keys/HoneypotPort | jq '.node.value' | sed 's/.//;s/.$//')`

publicipkibana=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipkibana | jq '.node.value' | sed 's/.//;s/.$//')`
publicipelastic=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipelastic | jq '.node.value' | sed 's/.//;s/.$//')`
publicipnginxproxy=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipnginxproxy | jq '.node.value' | sed 's/.//;s/.$//')`

urlkibana=`(curl http://127.0.0.1:4001/v2/keys/elk/urlkibana | jq '.node.value' | sed 's/.//;s/.$//')`
urlelastic=`(curl http://127.0.0.1:4001/v2/keys/elk/urlelastic | jq '.node.value' | sed 's/.//;s/.$//')`
urlnginxproxy=`(curl http://127.0.0.1:4001/v2/keys/elk/urlnginxproxy | jq '.node.value' | sed 's/.//;s/.$//')`

HoneypotImageK2=`(curl http://127.0.0.1:4001/v2/keys/localhoneypot2/containername | jq '.node.value' | sed 's/.//;s/.$//')`
honeypotport=`(curl http://127.0.0.1:4001/v2/keys/localhoneypot2/honeypotport | jq '.node.value' | sed 's/.//;s/.$//')`

appname=`(curl http://127.0.0.1:4001/v2/keys/cf-honeypot1/appname | jq '.node.value' | sed 's/.//;s/.$//')`
urlcfhoneypot=`(curl http://127.0.0.1:4001/v2/keys/cf-honeypot1/url | jq '.node.value' | sed 's/.//;s/.$//')`

localipk=`(curl http://127.0.0.1:4001/v2/keys/maininstance/ip | jq '.node.value' | sed 's/.//;s/.$//')`

faasurlk=`(curl http://127.0.0.1:4001/v2/keys/faas-honeypot/url | jq '.node.value' | sed 's/.//;s/.$//')`



echo " "
echo "   _____ _____ "
echo " / ____|_   _| "
echo " | |      | |  "
echo " | |      | |  "
echo " | |____ _| |_ "
echo "  \_____|_____|"
echo " "

#Tests Honeypots
#remember that honeypots could also live on swarm-master
#limit that by launching a fake container locking the port used by Honepots??

echo ""
echo "$(tput setaf 1)Testing ELK on Kubernetes $(tput sgr 0)"
echo ""

#kibana
REMOTEHOST=$publicipkibana
REMOTEPORT=80
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/elk/kibanaTEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/elk/kibanaTEST -XPUT -d value=FAILED
fi

#elastic
REMOTEHOST=$publicipelastic
REMOTEPORT=80
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/elk/elasticTEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/elk/elasticTEST -XPUT -d value=FAILED
fi

#logstash
REMOTEHOST=$publicipnginxproxy
REMOTEPORT=80
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/elk/logstashTEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/elk/logstashTEST -XPUT -d value=FAILED
fi


echo ""
echo "$(tput setaf 1)Testing local honeypot $(tput sgr 0)"
echo ""

#local honeypot

REMOTEHOST=$localipk
REMOTEPORT=8081
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/localhoneypot2/TEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/localhoneypot2/TEST -XPUT -d value=FAILED
fi

echo""
   echo""
   echo curl testing
   #curl ${REMOTEHOST}:${REMOTEPORT}
   curltestk=`(curl ${REMOTEHOST}:${REMOTEPORT})`
   #echo $curltestk
   #searchString="result":" ok"
   searchString="result"
   case $curltestk in
    #"$searchString") echo YES;;
    *"$searchString"*) curl -L http://127.0.0.1:4001/v2/keys/localhoneypot2/SYNTHETICTEST -XPUT -d value=PASSED;;
    *) curl -L http://127.0.0.1:4001/v2/keys/localhoneypot2/SYNTHETICTEST -XPUT -d value=FAILED ;;
   esac
   echo ""
   echo ""


echo ""
echo "$(tput setaf 1)Testing cf honeypot $(tput sgr 0)"
echo ""

#


REMOTEHOST=$urlcfhoneypot
REMOTEPORT=80
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/TEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/TEST -XPUT -d value=FAILED
fi

echo""
   echo""
   echo curl testing
   #curl ${REMOTEHOST}:${REMOTEPORT}
   curltestk=`(curl ${REMOTEHOST}:${REMOTEPORT})`
   #echo $curltestk
   #searchString="result":" ok"
   searchString="result"
   case $curltestk in
    #"$searchString") echo YES;;
    *"$searchString"*) curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/SYNTHETICTEST -XPUT -d value=PASSED;;
    *) curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/SYNTHETICTEST -XPUT -d value=FAILED ;;
   esac
   echo ""
   echo ""

#testing faas

echo ""
echo "$(tput setaf 1)Testing FaaS honeypot $(tput sgr 0)"
echo ""

REMOTEHOST=$faasurlk
REMOTEPORT=80
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/faas-honeypot/TEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/faas-honeypot/TEST -XPUT -d value=FAILED
fi

echo""
   echo""
   echo curl testing
   #curl ${REMOTEHOST}:${REMOTEPORT}
   curltestk=`(curl ${REMOTEHOST}:${REMOTEPORT})`
   #echo $curltestk
   #searchString="result":" ok"
   searchString="result"
   case $curltestk in
    #"$searchString") echo YES;;
    *"$searchString"*) curl -L http://127.0.0.1:4001/v2/keys/faas-honeypot/SYNTHETICTEST -XPUT -d value=PASSED;;
    *) curl -L http://127.0.0.1:4001/v2/keys/faas-honeypot/SYNTHETICTEST -XPUT -d value=FAILED ;;
   esac
   echo ""
   echo ""



#Test if ingress are healthy



echo ""
echo "$(tput setaf 1)Testing maininstance $(tput sgr 0)"
echo ""

#maininstance
REMOTEHOST=$localipk
REMOTEPORT=4001
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/maininstance/port4001TEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/maininstance/port4001TEST -XPUT -d value=FAILED
fi


#maininstance
REMOTEHOST=$localipk
REMOTEPORT=8000
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/maininstance/port8000TEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/maininstance/port8000TEST -XPUT -d value=FAILED
fi

#maininstance
REMOTEHOST=$localipk
REMOTEPORT=8081
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "$(tput setaf 2) I was able to connect to ${REMOTEHOST}:${REMOTEPORT} $(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/maininstance/port8081TEST -XPUT -d value=PASSED
else
    echo "$(tput setaf 1) Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?).$(tput sgr 0)"
    curl -L http://127.0.0.1:4001/v2/keys/maininstance/port8081TEST -XPUT -d value=FAILED
fi

echo ""
echo "$(tput setaf 6)Testing Finished: check etcd-browser for results $(tput sgr 0)"
echo ""


#TEST basic
#REMOTEHOST=8.8.8.8
#REMOTEPORT=53
#TIMEOUT=1

#if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
#    echo "I was able to connect to ${REMOTEHOST}:${REMOTEPORT}"
#else
#    echo "Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?)."
#fi



#Publish the results in a Dockerized web server

#Provide a status
