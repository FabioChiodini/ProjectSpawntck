# Code to deploy an honeypot to Kubenerytes using istio to monitor traffic
# High level flow
# Deploys Honeypot
# Deploys ingress

#Must use Cloud1 for accounts (any way to change this?)
#Some variables are modified later by fetching data from etcd
. /home/ec2-user/Cloud1
echo "loaded Config file"

echo ""
echo "STARTING"
echo ""


echo ""
echo "$(tput setaf 2) Loading env variables from etcd $(tput sgr 0)"
echo ""
#Variables needed

#gets data from previous run
MYDESTVALUE=`(curl http://127.0.0.1:4001/v2/keys/elk/publicipnginxproxy | jq '.node.value' | sed 's/.//;s/.$//')`


#Dinamycally read the location of the honeypot receiver

# sample value for your variables
#MYDESTVALUE="nginx:latest"

echo ""
echo "Address of Honeypot receiver"
echo $MYDESTVALUE
echo ""

# read the yml template from a file and substitute the string 
# {{MYVARNAME}} with the value of the MYVARVALUE variable
template=`cat "honeypot-istio/honey-istio-deployment.yaml" | sed "s/{{MYDESTNAME}}/$MYDESTVALUE/g"`

echo $template

# apply the yml with the substituted value
#echo "$template" | kubectl apply -f -
