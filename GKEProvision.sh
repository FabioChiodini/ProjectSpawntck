
#Overview
# Load config files
# Prepare etcd and other infrastructure services
# Start Kubernetes cluster
# Log Kubernetes cluster variables in etcd
# Execute ELK on Kubernetes
# Log ELK variables in etcd
# Launch honeypots


#Load config files
#Load Env variables from File (maybe change to DB)
#using /home/ec2-user/Cloud1
#source /home/ec2-user/Cloud1
. /home/ec2-user/Cloud1
echo ""
echo "Loaded Config file"
echo ""
echo "$(tput setaf 2) Starting $VM_InstancesK Instances in AWS $(tput sgr 0)"
if [ $GCEKProvision -eq 1 ]; then
  echo "$(tput setaf 2) Starting $GCEVM_InstancesK Instances in GCE $(tput sgr 0)"
fi
echo "$(tput setaf 2) Starting $Container_InstancesK Container Instances $(tput sgr 0)"


#Install jq

echo ""
echo "$(tput setaf 2) Installing jq $(tput sgr 0)"
echo ""
wget http://stedolan.github.io/jq/download/linux64/jq

chmod +x ./jq

sudo cp -p jq /usr/bin

echo ""
echo "STARTING"
echo ""


#Install local etcd

echo ""
echo "$(tput setaf 2) Creating a LOCAL etcd instance  $(tput sgr 0)"
echo ""

ipAWSK=`(curl http://169.254.169.254/latest/meta-data/public-ipv4)`
#docker run -d -v /usr/share/ca-certificates/:/etc/ssl/certs -p 4001:4001 -p 2380:2380 -p 2379:2379 --name etcdk quay.io/coreos/etcd -name etcd0 -advertise-client-urls http://${ipAWSK}:2379,http://${ipAWSK}:4001 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 -initial-advertise-peer-urls http://${ipAWSK}:2380 -listen-peer-urls http://0.0.0.0:2380 -initial-cluster-token etcd-cluster-1 -initial-cluster etcd0=http://${ipAWSK}:2380 -initial-cluster-state new

docker run -d -v /usr/share/ca-certificates/:/etc/ssl/certs -p 4001:4001 -p 2380:2380 -p 2379:2379 \
    --name etcdk quay.io/coreos/etcd:v3.1.0-rc.1 \
    /usr/local/bin/etcd \
    --name etcd0 \
    --advertise-client-urls http://${ipAWSK}:2379,http://${ipAWSK}:4001 \
    --listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
    --initial-advertise-peer-urls http://${ipAWSK}:2380 \
    --listen-peer-urls http://0.0.0.0:2380 \
    --initial-cluster-token etcd-cluster-1 \
    --initial-cluster etcd0=http://${ipAWSK}:2380 -initial-cluster-state new



#Create Kubernetes cluster

gcloud container clusters create delltechdemo123

#Currently using v1.7.12-gke.0

# It takes a few minutes to do this
echo "Sleeping for 5 minutes to let the provisioning finish"

sleep 5m

kubectl get nodes

kubectl create -f kubefiles/ -R --namespace=default

kubectl get pods,deployments,services,ingress,configmaps

echo "Sleeping for 2 minutes to let the Pods provisioning finish"
sleep 5m

kubectl get pods,deployments,services,ingress,configmaps

#After getting the ingress IPs it takes a few minutes for the services to be visible on the external ip


publicipKibana=$(kubectl get ing/all-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

publicipelastic=$(kubectl get ing/elasticsearch-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")


# Kubernetes Setup

kubernetescontext=$(kubectl config view -o jsonpath="{.current-context}")

kubcluster=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "gke_tactile-phalanx-189106_us-central1-a_delltechdemo123")].cluster.server}')

# kubectl delete -f kubefiles/ -R --namespace=default

# gcloud container clusters delete delltechdemo123 --quiet
