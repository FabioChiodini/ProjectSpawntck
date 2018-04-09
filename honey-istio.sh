# Code to deploy an honeypot to Kubenerytes using istio to monitor traffic
# High level flow
# Deploys Honeypot
# Deploys ingress

#Must use Cloud1 for accounts (any way to change this?)
#Some variables are modified later by fetching data from etcd
. /home/$USER/Cloud1
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
istioinstalled=`(curl http://127.0.0.1:4001/v2/keys/istio/installed | jq '.node.value' | sed 's/.//;s/.$//')`
#http://127.0.0.1:4001/v2/keys/istio/installed

if [ $istioinstalled -eq 1 ]; then
  #Dinamycally read the location of the honeypot receiver
  # sample value for your variables
  #MYDESTVALUE="nginx:latest"
  
  #Create ip for honey-istio
  echo ""
  echo "$(tput setaf 2) Creating an ip on GCP for honey-istio proxy  $(tput sgr 0)"
  echo ""

  gcloud compute addresses create honey-istio-ingress --global

  echo ""
  echo "Address of Honeypot receiver"
  echo $MYDESTVALUE
  echo ""

  # read the yml template from a file and substitute the string 
  # {{MYVARNAME}} with the value of the MYVARVALUE variable
  template=`cat "honeypot-istio/honey-istio-deployment.yaml" | sed "s/{{MYDESTNAME}}/$MYDESTVALUE/g"`
  destdirk=honeypot-istio/honey-istio-deployment-destvalue.yaml
  echo "$template" > "$destdirk"
  
  #  echo ""
  #  echo "Deploying honeypot with envoy sidecar"
  #  echo""
  #  istioctl kube-inject -f logstash/logstash-deployment.yaml -o logstash/logstash-deployment-injected.yaml
  #  kubectl create -f logstash/logstash-deployment-injected.yaml --namespace=default 
  #echo $template

  echo ""
  echo "$(tput setaf 2) Launching an honeypot instance in Kubernetes (with istio service mesh) logging to $MYDESTVALUE $(tput sgr 0)"
  echo ""

  # apply the yml with the substituted value
  echo "$template" | kubectl apply -f -
  
  #service
  kubectl expose deployment honey-istio --type NodePort
  

  #ingress
  kubectl create -f honeypot-istio/honey-istio-ingress.yaml --namespace=default
  
  #registers in etcd
  publiciphoneyistio=$(kubectl get ing/honey-istio-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
  curl -L http://127.0.0.1:4001/v2/keys/honeypot-istio/publiciphoneyistio -XPUT -d value=$publiciphoneyistio
  
  echo ""
  echo "$(tput setaf 2) Honeypot with Istio available at $publiciphoneyistio $(tput sgr 0)"
  echo ""
  

else
  echo ""
  echo "$(tput setaf 1) istio is NOT INSTALLED $(tput sgr 0)"
  echo "$(tput setaf 1) istio is NOT INSTALLED $(tput sgr 0)"
  echo "$(tput setaf 1) istio is NOT INSTALLED $(tput sgr 0)"
  echo "$(tput setaf 1) EXITING $(tput sgr 0)"
  echo""
fi



