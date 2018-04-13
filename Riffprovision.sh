#Builds container that logs to the current ELK stack

#Injects the ELK ip into the container code

# read the yml template from a file and substitute the string 
# {{MYVARNAME}} with the value of the MYVARVALUE variable
template=`cat "serverless/honeypot.py" | sed "s/{{MYDESTNAME}}/$MYDESTVALUE/g"`
destdirk=serverless/container/honeypot.py
echo "$template" > "$destdirk"


#cd serverless
#docker build -t kiodo/receiver:latest .
docker build -t kiodo/tcfaas:latest serverless


#create topic
kubectl apply -f serverless/topics/tcfaas-topic.yaml

#create function
kubectl apply -f serverless/functions/tcfaas-function.yaml

#Checks deployment
kubectl get deployment tcfaas

#checks that no pod are started (it's serverless!!)
kubectl get pods
