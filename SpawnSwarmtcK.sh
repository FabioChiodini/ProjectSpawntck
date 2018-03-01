
#Overview
# Load config files
# Prepare etcd and other infrastructure services
# Connect to Kubernetes cluster
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


#Install local etcd browser 

echo ""
echo "$(tput setaf 2) Creating a LOCAL etcd Browser instance  $(tput sgr 0)"
echo ""

  #creates name
  etcdbrowserkVMName=etcd-browserk$instidk
  
  publicipetcdbrowser=$ipAWSK
  
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




echo ""
echo "$(tput setaf 2) Starting ELK in the remote Kubernetes Cluster  $(tput sgr 0)"
echo ""

echo "Connected the remote Kubernetes Cluster"

echo ""
kubectl config current-context
echo ""
kubectl get nodes


#Create ip for nginx
echo ""
echo "Creating an ip on GCP for nginx proxy"
echo ""

gcloud compute addresses create kubernetes-ingress --global



# Creates config map for nginx from file

echo ""
echo "Creating ConfigMaps"
echo ""

kubectl create configmap nginxproxy-config --from-file=kubefiles/config/default.conf

kubectl create configmap logstash-config --from-file=kubefiles/config/logstash.conf



sleep 5s
echo ""
kubectl create -f kubefiles/ -R --namespace=default
echo""

echo "Creating an nginx proxy for logstash"
echo ""

#deployment
kubectl create -f nginxproxy/nginxproxy-deployment.yaml --namespace=default

#create default service for nginx

kubectl expose deployment nginxproxy --type NodePort

#ingress
kubectl create -f nginxproxy/nginxproxy-ingress.yaml --namespace=default

#Starts a local honeypot inside the kubernetes environment for testing purposes

echo ""
echo "$(tput setaf 2) Creating local honeypot in Kubernetes for internal testing purposes $(tput sgr 0)"
echo ""

kubectl create -f honeypot/ -R --namespace=default

echo ""

kubectl get pods,deployments,services,ingress,configmaps

echo ""

echo "Sleeping for 5 minutes to let the Pods provisioning finish"
sleep 5m

kubectl get pods,deployments,services,ingress,configmaps

#After getting the ingress IPs it takes a few minutes for the services to be visible on the external ip


publicipkibana=$(kubectl get ing/all-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

publicipelastic=$(kubectl get ing/elasticsearch-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

publiciplogstash=$(kubectl get ing/logstash-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

publicipnginxproxy=$(kubectl get ing/nginxproxy-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

# Sets public ip logstash to the public ip of nginx
# publiciplogstash=$(kubectl get ing/nginxproxy-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")


#register ELK and nginx public ips in etcd

curl -L http://127.0.0.1:4001/v2/keys/elk/publicipkibana -XPUT -d value=$publicipkibana

curl -L http://127.0.0.1:4001/v2/keys/elk/publicipelastic -XPUT -d value=$publicipelastic

curl -L http://127.0.0.1:4001/v2/keys/elk/publiciplogstash -XPUT -d value=$publiciplogstash

curl -L http://127.0.0.1:4001/v2/keys/elk/publicipnginxproxy -XPUT -d value=$publicipnginxproxy

#Sets publiciplogstash to nginx ingress
# curl -L http://127.0.0.1:4001/v2/keys/elk/publiciplogstash -XPUT -d value=$publicipnginxproxy



echo ----
echo "$(tput setaf 6) Kibana RUNNING ON $publicipkibana $(tput sgr 0)"
echo "$(tput setaf 4) $publicipkibana $(tput sgr 0)"
echo ----

echo ----
echo "$(tput setaf 6) elasticsearch RUNNING ON $publicipelastic $(tput sgr 0)"
echo "$(tput setaf 4) $publicipelastic $(tput sgr 0)"
echo ----

echo ----
echo "$(tput setaf 6) logstash public ip available ON $publiciplogstash $(tput sgr 0)"
echo "$(tput setaf 4) $publiciplogstash $(tput sgr 0)"
echo ----


urlkibana=http://$publicipkibana
urlelastic=http://$publicipelastic
urllogstash=http://$publiciplogstash

curl -L http://127.0.0.1:4001/v2/keys/elk/urlkibana -XPUT -d value=$urlkibana
curl -L http://127.0.0.1:4001/v2/keys/elk/urlelastic -XPUT -d value=$urlelastic
curl -L http://127.0.0.1:4001/v2/keys/elk/urllogstash -XPUT -d value=$urllogstash



# register Kubernetes Setup parameters in etcd
echo "Registering Kubernetes Cluster parameters in etcd"

kubernetescontext=$(kubectl config view -o jsonpath="{.current-context}")

kubcluster=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "gke_tactile-phalanx-189106_us-central1-a_delltechdemo123")].cluster.server}')

curl -L http://127.0.0.1:4001/v2/keys/k8s/kubernetescontext -XPUT -d value=$kubernetescontext
curl -L http://127.0.0.1:4001/v2/keys/k8s/kubcluster -XPUT -d value=$kubcluster

#Add number of nodes/worloads?


# Launch local honeypot (this will log to elasticsearch)

#Launches Honeypot that logs to logstash endpoint
    #docker run -d --name honeypot-$i -p $HoneypotPortK:$HoneypotPortK $HoneypotImageK
    docker run -d --name honeypot-i -e LOG_HOST=$publiciplogstash -e LOG_PORT=$ReceiverPortK -p $HoneypotPortK:$HoneypotPortK $HoneypotImageK 
#Creates a second honeypot that logs to nginxproxy
docker run -d --name honeypot-nginx -e LOG_HOST=$publicipnginxproxy -e LOG_PORT=$ReceiverPortK -p 8081:$HoneypotPortK $HoneypotImageK 
#launches nginx (optional)

#launches nginx (optional)

#Registers honeypot parameters in etcd

curl -L http://127.0.0.1:4001/v2/keys/honeypots/containername -XPUT -d value=$HoneypotImageK
curl -L http://127.0.0.1:4001/v2/keys/honeypots/honeypotport -XPUT -d value=$HoneypotPortK
curl -L http://127.0.0.1:4001/v2/keys/honeypots/receiverip -XPUT -d value=$publiciplogstash
curl -L http://127.0.0.1:4001/v2/keys/honeypots/receiverport -XPUT -d value=$ReceiverPortK


echo ----
echo "$(tput setaf 6) Local honeypot RUNNING ON $ipAWSK:$HoneypotPortK $(tput sgr 0)"
echo "$(tput setaf 6) Local honeypot sending logs to $publiciplogstash PORT $ReceiverPortK$(tput sgr 0)"
echo "$(tput setaf 4) Open a browser to : $ipAWSK:8080 $(tput sgr 0)"
echo ----

echo ----
echo "$(tput setaf 6) Test honeypot RUNNING ON $ipAWSK:8081 $(tput sgr 0)"
echo "$(tput setaf 6) Local honeypot sending logs to $publicipnginxproxy PORT 8081(tput sgr 0)"
echo "$(tput setaf 4) Open a browser to : $ipAWSK:8081 $(tput sgr 0)"
echo ----


#Poll local honeypot
# curl $ipAWSK:$HoneypotPortK
curl $ipAWSK:$HoneypotPortK

echo ----
echo "$(tput setaf 6) $etcdbrowserkVMName RUNNING ON $publicipetcdbrowser:8000 $(tput sgr 0)"
echo "$(tput setaf 4) publicipetcdbrowser=$publicipetcdbrowser $(tput sgr 0)"
echo ----

echo "Demo by @FabioChiodini"
# kubectl delete -f kubefiles/ -R --namespace=default

# gcloud container clusters delete delltechdemo123 --quiet
