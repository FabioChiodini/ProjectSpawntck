
#Overview
# Load config files
# Start Kubernetes cluster


#Load config files
#Load Env variables from File (maybe change to DB)
#using /home/ec2-user/Cloud1
#source /home/ec2-user/Cloud1
. /home/$USER/Cloud1
echo ""
echo "Loaded Config file"
echo ""
#echo "$(tput setaf 2) Starting $VM_InstancesK Instances in AWS $(tput sgr 0)"
#if [ $GCEKProvision -eq 1 ]; then
#  echo "$(tput setaf 2) Starting $GCEVM_InstancesK Instances in GCE $(tput sgr 0)"
#fi
#echo "$(tput setaf 2) Starting $Container_InstancesK Container Instances $(tput sgr 0)"


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



#Create Kubernetes cluster
echo ""
echo "$(tput setaf 2) Creating Kubernetes Cluster in GKE  $(tput sgr 0)"
echo ""


if [ -z "$K8sVersion" ]; then
  K8sVersion=1.8.10-gke.0
fi

#echo "Creating Kubernetes Cluster in GKE"

gcloud container clusters create --cluster-version=$K8sVersion delltechdemo123

#Previously using v1.7.12-gke.0

# It takes a few minutes to do this
echo "Sleeping for 30 seconds to let the provisioning finish"
echo ""

sleep 30s

kubectl get nodes
kubectl get services

echo " Cluster"
kubectl config current-context
echo "created"


echo ""
echo "Demo by @FabioChiodini"
echo ""
# kubectl delete -f kubefiles/ -R --namespace=default

# gcloud container clusters delete delltechdemo123 --quiet
