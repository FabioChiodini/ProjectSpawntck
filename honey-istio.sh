# Code to deploy an honeypot to Kubenerytes using istio to monitor traffic
# High level flow
# Deploys Honeypot
# Deploys ingress

#Dinamycally read the location of the honeypot receiver

# sample value for your variables
MYDESTVALUE="nginx:latest"

echo ""
echo $MYDESTVALUE
echo ""

# read the yml template from a file and substitute the string 
# {{MYVARNAME}} with the value of the MYVARVALUE variable
template=`cat "honeypot-istio/honey-istio-deployment.yaml" | sed "s/{{MYDESTNAME}}/$MYDESTVALUE/g"`

echo $template

# apply the yml with the substituted value
#echo "$template" | kubectl apply -f -
