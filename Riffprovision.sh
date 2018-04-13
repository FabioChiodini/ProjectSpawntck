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


#docker push
#docker push kiodo/tcfaas:latest


#create topic
kubectl apply -f serverless/topics/tcfaas-topic.yaml

#create function
kubectl apply -f serverless/functions/tcfaas-function.yaml

#Checks deployment
kubectl get deployment tcfaas

#checks that no pod are started (it's serverless!!)
kubectl get pods

echo ""
echo " Access the function using"
echo " curl http://$publicipriff/requests/tcfaas"
echo ""
