# Overview
# Installs Helm
# Installs riff

echo ""
echo "$(tput setaf 2) Installing riff in the Kubernetes Cluster  $(tput sgr 0)"
echo ""


echo ""
echo "$(tput setaf 2) Installing Helm in the Kubernetes Cluster  $(tput sgr 0)"
echo ""

#removing CPU limits
kubectl delete limitrange limits

echo ""

#Adding cluster-admin permissions
export GCP_USER=$(gcloud config get-value account | head -n 1)
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$GCP_USER

echo ""

#echo "Installing local Helm client"

#curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
#chmod 700 get_helm.sh
#/get_helm.sh


#Add repo to Helm
helm repo add projectriff https://riff-charts.storage.googleapis.com
helm repo update

# Install Helm
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account=tiller


#echo "Installing Helm on Kubernetes"
#helm init

echo ""
echo "Sleeping for 60 seconds to let the provisioning finish"
echo ""

sleep 60s

# Check to see if Helm has been installed
kubectl get pods --namespace kube-system

echo ""

# Check to see if Tiller is running
kubectl get pod --namespace kube-system -l app=helm

echo ""

#Checks versions
helm version

echo ""
echo "$(tput setaf 2) Installing project riff in the Kubernetes Cluster  $(tput sgr 0)"
echo ""

#Add repo to Helm
helm repo add projectriff https://riff-charts.storage.googleapis.com
helm repo update

# Create a riff namespace in Kubernetes
kubectl create namespace riff-system

echo ""

# Install kafka for riff
#helm install riffrepo/kafka \
# goof fopr version 0.0.5
#helm install projectriff/kafka \
#  --name transport \
#  --namespace riff-system

#echo ""
#echo "Sleeping for 60 seconds to let the provisioning finish"
#echo ""

#sleep 60s


#helm install projectriff/riff \
#  --name control \
#  --namespace riff-system


#ver 0.0.6
helm install projectriff/riff \
  --name projectriff \
  --namespace riff-system \
  --set kafka.create=true
 
 
#helm install riffrepo/riff --name delltechriff123 --namespace riff-system

echo ""
echo "Sleeping for 2 minutes to let the provisioning finish"
echo ""

sleep 2m



kubectl get svc,deployments,pods,functions,topics --namespace riff-system
# kubectl get po,deploy --namespace riff-system

kubectl get svc --namespace riff-system control-riff-http-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

echo ""
#SERVICE_IP=$(kubectl get svc --namespace riff-system control-riff-http-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SERVICE_IP=$(kubectl get svc --namespace riff-system projectriff-riff-http-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Service ip $SERVICE_IP"
echo ""

urlriff=http://$SERVICE_IP

echo ""
echo "riff URL $urlriff"
echo ""




echo ""
echo "$(tput setaf 2) Installing riff CLI  $(tput sgr 0)"
echo ""
#curl -Lo riff-linux-amd64.tgz https://github.com/projectriff/riff/releases/download/v0.0.5/riff-linux-amd64.tgz
curl -Lo riff-linux-amd64.tgz https://github.com/projectriff/riff/releases/download/v0.0.6/riff-linux-amd64.tgz
tar xvzf riff-linux-amd64.tgz
sudo mv riff /usr/local/bin/

echo ""
riff version
riff list
echo ""

#Installing invokers

echo ""
echo "Installing riff invokers"
echo ""

riff invokers apply -f https://github.com/projectriff/command-function-invoker/raw/v0.0.6/command-invoker.yaml
riff invokers apply -f https://github.com/projectriff/go-function-invoker/raw/v0.0.2/go-invoker.yaml
riff invokers apply -f https://github.com/projectriff/java-function-invoker/raw/v0.0.5-sr.1/java-invoker.yaml
riff invokers apply -f https://github.com/projectriff/node-function-invoker/raw/v0.0.6/node-invoker.yaml
riff invokers apply -f https://github.com/projectriff/python2-function-invoker/raw/v0.0.6/python2-invoker.yaml
riff invokers apply -f https://github.com/projectriff/python3-function-invoker/raw/v0.0.6/python3-invoker.yaml

sleep 30s

echo ""
echo "$(tput setaf 2) riff available at $urlriff $(tput sgr 0)"
echo ""

echo ""
echo "Demo by @FabioChiodini"
echo ""
