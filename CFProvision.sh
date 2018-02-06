#Code to scale up after first Spawn
#Still TBI

#Must use Cloud1 for accounts (any way to change this?)
#Some variables are modified later by fetching data from etcd
. /home/ec2-user/Cloud1
echo "loaded Config file"

echo ""
echo "STARTING"
echo ""


#gets data from previous run

#etcd
etcdbrowserkVMName=`(curl http://127.0.0.1:4001/v2/keys/etcd-browser/name | jq '.node.value' | sed 's/.//;s/.$//')`
publicipetcdbrowser=`(curl http://127.0.0.1:4001/v2/keys/etcd-browser/address | jq '.node.value' | sed 's/.//;s/.$//')`

#AWS ip
ipAWSK=`(curl http://127.0.0.1:4001/v2/keys/maininstance/ip | jq '.node.value' | sed 's/.//;s/.$//')`

#ELK stack
publicipkibana=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipkibana | jq '.node.value' | sed 's/.//;s/.$//')`
publicipelastic=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipelastic | jq '.node.value' | sed 's/.//;s/.$//')`
publiciplogstash=`(curl http://127.0.0.1:4001/v2/keys/elk/publiciplogstash | jq '.node.value' | sed 's/.//;s/.$//')`

#Honeypots

HoneypotImageK=`(curl http://127.0.0.1:4001/v2/keys/honeypots/containername | jq '.node.value' | sed 's/.//;s/.$//')`
HoneypotPortK=`(curl http://127.0.0.1:4001/v2/keys/honeypots/honeypotport | jq '.node.value' | sed 's/.//;s/.$//')`
publiciplogstash=`(curl http://127.0.0.1:4001/v2/keys/honeypots/receiverip | jq '.node.value' | sed 's/.//;s/.$//')`
ReceiverPortK=`(curl http://127.0.0.1:4001/v2/keys/honeypots/receiverport | jq '.node.value' | sed 's/.//;s/.$//')`

HoneypotPortKj=8081

#Launches additional local
    #docker run -d --name honeypot-$i -p $HoneypotPortK:$HoneypotPortK $HoneypotImageK
    docker run -d --name honeypot-j -e LOG_HOST=$publiciplogstash -e LOG_PORT=$ReceiverPortK -p $HoneypotPortK:$HoneypotPortKj $HoneypotImageK 
#launches nginx (optional)

echo ----
echo "$(tput setaf 6) Local honeypot RUNNING ON $ipAWSK:$HoneypotPortKj $(tput sgr 0)"
echo "$(tput setaf 6) Local honeypot sending logs to $publiciplogstash PORT $ReceiverPortK$(tput sgr 0)"
echo "$(tput setaf 4) Open a browser to : $ipAWSK:$HoneypotPortKj (tput sgr 0)"
echo ----

echo "@FabioChiodini"


