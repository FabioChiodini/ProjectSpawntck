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
publicipnginxproxy=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipnginxproxy | jq '.node.value' | sed 's/.//;s/.$//')`

#Honeypots

HoneypotImageK=`(curl http://127.0.0.1:4001/v2/keys/honeypots/containername | jq '.node.value' | sed 's/.//;s/.$//')`
HoneypotPortK=`(curl http://127.0.0.1:4001/v2/keys/honeypots/honeypotport | jq '.node.value' | sed 's/.//;s/.$//')`
publiciplogstash=`(curl http://127.0.0.1:4001/v2/keys/honeypots/receiverip | jq '.node.value' | sed 's/.//;s/.$//')`
ReceiverPortK=`(curl http://127.0.0.1:4001/v2/keys/honeypots/receiverport | jq '.node.value' | sed 's/.//;s/.$//')`

#Customizing the manifest yml

MYDESTVALUE=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipnginxproxy | jq '.node.value' | sed 's/.//;s/.$//')`

echo ""
echo "Address of Honeypot receiver"
echo $MYDESTVALUE
echo ""

# read the yml template from a file and substitute the string 
  # {{MYVARNAME}} with the value of the MYVARVALUE variable
  template=`cat "cf/template/manifesttemplate.yml" | sed "s/{{MYDESTNAME}}/$MYDESTVALUE/g"`
  destdirk=cf/template/manifesttemplate-1.yml
echo "$template" > "$destdirk"

#adds a unique name
MYNAMEVALUE=-UNI1-$instidk
# read the yml template from a file and substitute the string 
  # {{MYVARNAME}} with the value of the MYVARVALUE variable
  template=`cat "cf/template/manifesttemplate-1.yml" | sed "s/{{MYUNIQUENAME}}/$MYNAMEVALUE/g"`
  destdirk=cf/manifest.yml
echo "$template" > "$destdirk"


cf api $cfapik1

cd cf

cf login -u $cflogink1 -p $cfpassk1 -o $cforgk1

cf push

cd ..


#etcd
urlcfhoneypot=http://$MYNAMEVALUE

curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/appname -XPUT -d value=$MYNAMEVALUE
curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/url -XPUT -d value=urlcfhoneypot.cfapps.io
curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/api -XPUT -d value=$cfapik1
curl -L http://127.0.0.1:4001/v2/keys/cf-honeypot1/org -XPUT -d value=$cforgk1


echo "Demo by @FabioChiodini"


