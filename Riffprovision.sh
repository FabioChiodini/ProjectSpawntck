#!/bin/bash
#Loads variables
#Must use Cloud1 for accounts (any way to change this?)
#Some variables are modified later by fetching data from etcd
. /home/$USER/Cloud1
echo "loaded Config file"

#need login for dockerhub


#Builds container that logs to the current ELK stack

#Injects the ELK ip into the container code

#gets data from previous run
MYDESTVALUE=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipnginxproxy | jq '.node.value' | sed 's/.//;s/.$//')`

publicipriff=`(curl http://127.0.0.1:4001/v2/keys/riff/publicipriff | jq '.node.value' | sed 's/.//;s/.$//')`

# read the yml template from a file and substitute the string 
# {{MYVARNAME}} with the value of the MYVARVALUE variable
template=`cat "serverless/honeypot.py" | sed "s/{{MYDESTNAME}}/$MYDESTVALUE/g"`
destdirk=serverless/container/honeypot.py
echo "$template" > "$destdirk"

echo ""
echo "Building a pushing an updated tcfaas container"
echo ""

#cd serverless
#docker build -t kiodo/receiver:latest .
docker build -t kiodo/tcfaas:latest serverless/container

#docker login
docker login --username=$dologink --password=$dopassk

#docker push
docker push kiodo/tcfaas:latest

sleep 30s

echo ""

#create topic
kubectl apply -f serverless/topics/tcfaas-topic.yaml

echo ""

#create function
kubectl apply -f serverless/functions/tcfaas-function.yaml

#Checks deployment
kubectl get deployment tcfaas

echo ""

#checks that no pod are started (it's serverless!!)
kubectl get pods


#registering in service discovery

URLtcfaas=http://$publicipriff
curl -L http://127.0.0.1:4001/v2/keys/faas-honeypot/functionname -XPUT -d value=tcfaas
curl -L http://127.0.0.1:4001/v2/keys/faas-honeypot/url -XPUT -d value=$URLtcfaas/requests/tcfaas
curl -L http://127.0.0.1:4001/v2/keys/faas-honeypot/containerimage -XPUT -d value=kiodo/tcfaas

echo ""
echo "To show the servers in serverless"
echo "kubectl get svc,deployments,pods,functions,topics --namespace riff-system"
echo ""

echo ""
echo " Access the function using"
echo " curl http://$publicipriff/requests/tcfaas"
echo ""
