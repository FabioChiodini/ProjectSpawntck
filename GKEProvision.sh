
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


#Install etcd browser via docker machine

  #creates name
  etcdbrowserkVMName=etcd-browserk$instidk
  #Create Docker Receiver Instance in AWS
  docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION $etcdbrowserkVMName

  echo "$(tput setaf 2) Opening Ports for etcd-browser on AWS $(tput sgr 0)"
  #Opens Firewall Port for Receiver on AWS
  aws ec2 authorize-security-group-ingress --group-name docker-machine --protocol tcp --port 8000 --cidr 0.0.0.0/0

  #Connects to remote VM

  docker-machine env $etcdbrowserkVMName > /home/ec2-user/$etcdbrowserkVMName
  . /home/ec2-user/$etcdbrowserkVMName

  publicipetcdbrowser=$(docker-machine ip etcd-browserk$instidk)
  
  #launches etcd-browser containerized
  docker run -d --name etcd-browserk -p 0.0.0.0:8000:8000 --env ETCD_HOST=$DynDNSK kiodo/etcd-browser:latest
  
  #Register etcd-browser in etcd
  curl -L http://127.0.0.1:4001/v2/keys/etcd-browser/name -XPUT -d value=$etcdbrowserkVMName
  curl -L http://127.0.0.1:4001/v2/keys/etcd-browser/ip -XPUT -d value=$publicipetcdbrowser
  curl -L http://127.0.0.1:4001/v2/keys/etcd-browser/port -XPUT -d value=8000
  curl -L http://127.0.0.1:4001/v2/keys/etcd-browser/address -XPUT -d value=$publicipetcdbrowser:8000

echo ----
echo "$(tput setaf 6) $etcdbrowserkVMName RUNNING ON $publicipetcdbrowser:8000 $(tput sgr 0)"
echo "$(tput setaf 4) publicipetcdbrowser=$publicipetcdbrowser $(tput sgr 0)"
echo ----

#register local ip and dns name in etcd
myipK=$( dig +short $DynDNSK @8.8.8.8)
curl -L http://127.0.0.1:4001/v2/keys/maininstance/ip -XPUT -d value=$myipK
fqnK=$(nslookup $myipK)
fqnK=${fqnK##*name = }
fqnK=${fqnK%.*}
#echo $fqn
curl -L http://127.0.0.1:4001/v2/keys/maininstance/name -XPUT -d value=$fqnK

#register instance id in etcd
curl -L http://127.0.0.1:4001/v2/keys/maininstance/uniqueinstanceid -XPUT -d value=$instidk


#Create Kubernetes cluster

echo "Creating Kubernetes Cluster in GKE"

gcloud container clusters create delltechdemo123

#Currently using v1.7.12-gke.0

# It takes a few minutes to do this
echo "Sleeping for 5 minutes to let the provisioning finish"

sleep 5m

kubectl get nodes

echo "Starting ELK in the remote Kubernetes Cluster"

kubectl create -f kubefiles/ -R --namespace=default

kubectl get pods,deployments,services,ingress,configmaps

echo "Sleeping for 2 minutes to let the Pods provisioning finish"
sleep 5m

kubectl get pods,deployments,services,ingress,configmaps

#After getting the ingress IPs it takes a few minutes for the services to be visible on the external ip


publicipkibana=$(kubectl get ing/all-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

publicipelastic=$(kubectl get ing/elasticsearch-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

#register ELK public ips in etcd

curl -L http://127.0.0.1:4001/v2/keys/elk/publicipkibana -XPUT -d value=$publicipkibana

curl -L http://127.0.0.1:4001/v2/keys/elk/publicipelastic -XPUT -d value=$publicipelastic


# register Kubernetes Setup parameters in etcd
echo "Registering Kubernetes Cluster parameters in etcd"

kubernetescontext=$(kubectl config view -o jsonpath="{.current-context}")

kubcluster=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "gke_tactile-phalanx-189106_us-central1-a_delltechdemo123")].cluster.server}')

curl -L http://127.0.0.1:4001/v2/keys/k8s/kubernetescontext -XPUT -d value=$kubernetescontext
curl -L http://127.0.0.1:4001/v2/keys/k8s/kubcluster -XPUT -d value=$kubcluster

#Add number of nodes/worloads?


# kubectl delete -f kubefiles/ -R --namespace=default

# gcloud container clusters delete delltechdemo123 --quiet
