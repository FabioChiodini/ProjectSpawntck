# Overview
# Installs Istio

#install istio Client

wget https://github.com/istio/istio/releases/download/0.6.0/istio-0.6.0-linux.tar.gz

mkdir istio

#untars istio in an istio folder stripping the version number 

tar xzvf istio-0.6.0-linux.tar.gz -C istio --strip-components=1

sudo mkdir /bin/istio

sudo cp -p istio/bin/istioctl /bin/istio

export PATH=/bin/istio:$PATH

#Gives current user cluster-admin role

#removing CPU limits
kubectl delete limitrange limits

echo ""

#Adding cluster-admin permissions
export GCP_USER=$(gcloud config get-value account | head -n 1)
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$GCP_USER

echo ""


# Installs istio

kubectl apply -f istio/install/kubernetes/istio-auth.yaml

#Checks if istio is installed

kubectl get service -n istio-system

kubectl get pods -n istio-system

# Install Prometheus
kubectl apply -f istio/install/kubernetes/addons/prometheus.yaml

#Install grafana
kubectl apply -f istio/install/kubernetes/addons/grafana.yaml

# Checks grafana installation
kubectl -n istio-system get svc grafana

echo ""
echo "Creating ConfigMaps"
echo ""

kubectl create configmap nginxproxy-config-grafana --from-file=grafana/config/default.conf --namespace=istio-system

#deployment
kubectl create -f grafana/nginxproxy-grafana.yaml --namespace=default --namespace=istio-system


#create default service for nginx
kubectl expose deployment nginxproxy-grafana --type NodePort --namespace=istio-system


# Create grafana ingress

echo ""
echo "$(tput setaf 2) Creating an ip on GCP for grafana nginx proxy $(tput sgr 0)"
echo ""

gcloud compute addresses create grafana-ingress --global

echo ""

# Creates an ingress for an nginxproxy that points to grafana
kubectl create -f grafana/grafana-ingress.yaml --namespace=istio-system

echo ""
echo "Sleeping for 5 minutes to let the Pods provisioning finish"
echo ""

sleep 5m

publicipgrafana=$(kubectl get ing/grafana-ingress --namespace=istio-system -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

echo ""
echo "$(tput setaf 2) Grafana available at $publicipgrafana $(tput sgr 0)"
echo ""

echo ""
echo "$(tput setaf 2) istio dashboards available at $publicipgrafana/dashboard/db/istio-dashboard $(tput sgr 0)"
echo ""



