# Overview
# Installs Istio

#install istio Client

wget https://github.com/istio/istio/releases/download/0.6.0/istio-0.6.0-linux.tar.gz

mkdir istio

#untars istio in an istio folder stripping iut the version number 

tar xzvf istio-0.6.0-linux.tar.gz -C istio --strip-components=1

sudo mkdir /bin/istio

sudo cp -p istio/bin/istioctl /bin/istio

export PATH=/bin/istio:$PATH

#Gives current user cluster-admin role


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

# Create grafana ingress

echo ""
echo "$(tput setaf 2) Creating an ip on GCP for nginx proxy  $(tput sgr 0)"
echo ""

gcloud compute addresses create kubernetes-ingress --global




