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

cf api api.run.pivotal.io

cd cf

cf login -u $cflogink1 -p $cfpassk1 -o EVP

cf push

cd ..


echo "Demo by @FabioChiodini"


