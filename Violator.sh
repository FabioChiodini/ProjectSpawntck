# Script to clean up Kubernetes workloads and local docker files
# Avoid  the recreation of a full cluster

echo " "
echo " ______ _      _  __  _______ ______          _____  _____   ______          ___   _ "
echo "|  ____| |    | |/ / |__   __|  ____|   /\   |  __ \|  __ \ / __ \ \        / / \ | |"
echo "| |__  | |    | ' /     | |  | |__     /  \  | |__) | |  | | |  | \ \  /\  / /|  \| |"
echo "|  __| | |    |  <      | |  |  __|   / /\ \ |  _  /| |  | | |  | |\ \/  \/ / | .   |"
echo "| |____| |____| . \     | |  | |____ / ____ \| | \ \| |__| | |__| | \  /\  /  | |\  |"
echo "|______|______|_|\_\    |_|  |______/_/    \_\_|  \_\_____/ \____/   \/  \/   |_| \_|"
echo ""

#Must use Cloud1 for accounts (any way to change this?)
#Some variables are modified later by fetching data from etcd
. /home/ec2-user/Cloud1
echo "loaded Config file"

echo ""
echo "STARTING"
echo ""

MYNAMEVALUE=`(curl http://127.0.0.1:4001/v2/keys/cf-honeypot1/appname | jq '.node.value' | sed 's/.//;s/.$//')`

echo ""
echo "$(tput setaf 1)Destroying ELK Setup $(tput sgr 0)"
echo ""

kubectl delete cm nginxproxy-config
kubectl delete cm logstash-config
kubectl delete cm tcpnginx-config

kubectl delete service nginxproxy
kubectl delete service tcpnginx
kubectl delete service logstash

kubectl delete -f kubefiles/ -R --namespace=default

kubectl delete -f nginxproxy/ -R --namespace=default

kubectl delete -f tcpnginx/ -R --namespace=default

kubectl delete -f logstash/ -R --namespace=default

#destroys honeypot-istio
kubectl delete -f honeypot-istio/ -R --namespace=default

#destroys local honeypot instance in Kubernetes (testing instance)
kubectl delete -f honeypot/ -R --namespace=default

#destroys ghost 
kubectl delete deploy ghost
kubectl delete service ghost

kubectl get pods,deployments,services,ingress,configmaps

echo "Sleeping for 30 seconds to let the de-provisioning finish"
echo ""
sleep 30s

kubectl get pods,deployments,services,ingress,configmaps

echo ""
echo ""

kubectl get all

#Delete local docker containers

echo ""
echo "$(tput setaf 1) Removing nginxproxy ip from GCP $(tput sgr 0)"
echo ""

gcloud compute addresses delete --quiet  kubernetes-ingress --global

gcloud compute addresses delete --quiet logstash-ingress --global

gcloud compute addresses delete --quiet tcpnginx-ingress --global

gcloud compute addresses delete --quiet grafana-ingress --global

gcloud compute addresses delete --quiet honey-istio-ingress --global

gcloud compute addresses list --global

#Kill local containers
echo ""
echo "$(tput setaf 1) Destroying Local Containers $(tput sgr 0)"
echo ""
docker rm -f etcd-browserk$instidk
docker rm -f etcd-browserk
sleep 1
docker rm -f honeypot-logstash-1
sleep 1
docker rm -f honeypot-nginx-2
sleep 1
docker rm -f honeypot-nginx-3
sleep 1
docker rm -f etcdk

echo ""
echo "Local Docker instances running: "

docker ps

# kill remote cf honeypots
echo ""
echo "$(tput setaf 1) Destroying cf honeypots $(tput sgr 0)"
echo ""

cf api $cfapik1

cf login -u $cflogink1 -p $cfpassk1 -o $cforgk1

cf delete -f $MYNAMEVALUE

echo ""
echo "$(tput setaf 1) All Kubernetes deployments, honeypot on cf and local docker containers have been destroyed by Violator ;) $(tput sgr 0)"
echo ""

