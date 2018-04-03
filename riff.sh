# Overview
# Installs Helm
# Installs riff



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

# Install kafka for riff
#helm install riffrepo/kafka \
helm install projectriff/kafka \
  --name transport \
  --namespace riff-system

echo ""
echo "Sleeping for 60 seconds to let the provisioning finish"
echo ""

sleep 60s


helm install projectriff/riff \
  --name control \
  --namespace riff-system
  
#helm install riffrepo/riff --name delltechriff123 --namespace riff-system

echo ""
echo "Sleeping for 60 seconds to let the provisioning finish"
echo ""

sleep 60s

kubectl get svc,deployments,pods,functions,topics --namespace riff-system
# kubectl get po,deploy --namespace riff-system

kubectl get svc --namespace riff-system control-riff-http-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

echo ""
SERVICE_IP=$(kubectl get svc --namespace riff-system control-riff-http-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Service ip $SERVICE_IP"
echo ""

urlriff=http://$SERVICE_IP

echo ""
echo "riff URL $urlriff"
echo ""




echo ""
echo "$(tput setaf 2) Installing riff CLI  $(tput sgr 0)"
echo ""
curl -Lo riff-linux-amd64.tgz https://github.com/projectriff/riff/releases/download/v0.0.5/riff-linux-amd64.tgz
tar xvzf riff-linux-amd64.tgz
sudo mv riff /usr/local/bin/

echo ""
riff version
riff list
echo ""

echo ""
echo "Demo by @FabioChiodini"
echo ""
