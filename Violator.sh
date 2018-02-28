# Script to clean up Kubernetes workloads and local docker files
# Avoid  the recreation of a full cluster

echo " "
echo " ______ _      _  __  _______ ______          _____  _____   ______          ___   _ "
echo "|  ____| |    | |/ / |__   __|  ____|   /\   |  __ \|  __ \ / __ \ \        / / \ | |"
echo "| |__  | |    | ' /     | |  | |__     /  \  | |__) | |  | | |  | \ \  /\  / /|  \| |"
echo "|  __| | |    |  <      | |  |  __|   / /\ \ |  _  /| |  | | |  | |\ \/  \/ / | . ` |"
echo "| |____| |____| . \     | |  | |____ / ____ \| | \ \| |__| | |__| | \  /\  /  | |\  |"
echo "|______|______|_|\_\    |_|  |______/_/    \_\_|  \_\_____/ \____/   \/  \/   |_| \_|"
echo ""


echo ""
echo "$(tput setaf 1)Destroying ELK Setup $(tput sgr 0)"
echo ""

kubectl delete cm nginxproxy-config
kubectl delete cm logstash-config

kubectl delete -f kubefiles/ -R --namespace=default

#destroys local honeypot instance in Kubernetes (testing instance)
kubectl delete -f honeypot/ -R --namespace=default

kubectl get pods,deployments,services,ingress,configmaps

echo "Sleeping for 2 mins to let the de-provisioning finish"
echo ""
sleep 2m

kubectl get pods,deployments,services,ingress,configmaps

#Delete local docker containers

#Kill local containers
echo ""
echo "$(tput setaf 1) Destroying Local Containers $(tput sgr 0)"
echo ""
docker rm -f etcd-browserk$instidk
sleep 1
docker rm -f honeypot-i
sleep 1
docker rm -f honeypot-nginx
sleep 1
docker rm -f etcdk

echo ""
echo "Local Docker instances running: "

docker ps

echo ""
echo "$(tput setaf 1) All Kubernetes deployments and local docker containers has been destroyed by Violator ;) $(tput sgr 0)"
echo ""

