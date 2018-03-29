echo " "
echo "  _______ ______          _____    _____   ______          ___   _  "
echo " |__   __|  ____|   /\   |  __ \  |  __ \ / __ \ \        / / \ | | "
echo "    | |  | |__     /  \  | |__) | | |  | | |  | \ \  /\  / /|  \| | "
echo "    | |  |  __|   / /\ \ |  _  /  | |  | | |  | |\ \/  \/ / |     | "
echo "    | |  | |____ / ____ \| | \ \  | |__| | |__| | \  /\  /  | |\  | "
echo "    |_|  |______/_/    \_\_|  \_\ |_____/ \____/   \/  \/   |_| \_| "
echo " "


echo ""
echo "$(tput setaf 1)Destroying ELK Setup $(tput sgr 0)"
echo ""

echo ""
echo "$(tput setaf 1) Removing nginxproxy ip from GCP $(tput sgr 0)"
echo ""

gcloud compute addresses delete --quiet kubernetes-ingress --global

gcloud compute addresses delete --quiet logstash-ingress --global

gcloud compute addresses delete --quiet grafana-ingress --global

kubectl delete cm nginxproxy-config
kubectl delete cm logstash-config

kubectl delete service nginxproxy

kubectl delete service logstash

kubectl delete -f kubefiles/ -R --namespace=default

kubectl delete -f nginxproxy/ -R --namespace=default

kubectl delete -f logstash/ -R --namespace=default

#destroys local honeypot instance in Kubernetes (testing instance)
kubectl delete -f honeypot/ -R --namespace=default

#destroys ghost 
kubectl delete deploy ghost
kubectl delete service ghost

kubectl get pods,deployments,services,ingress,configmaps

echo "Sleeping for 2 mins to let the de-provisioning finish"

sleep 2m

kubectl get pods,deployments,services,ingress,configmaps

echo ""
echo "$(tput setaf 1)Destroying Kubernetes Cluster $(tput sgr 0)"
echo ""


echo ""
echo "Remote Kubernetes clusters instances running: "

gcloud container clusters delete delltechdemo123 --quiet

kubectl get nodes

#Delete local docker containers

#Kill local containers
echo ""
echo "$(tput setaf 1) Destroying Local Containers $(tput sgr 0)"
echo ""
docker rm -f etcd-browserk$instidk
sleep 1
docker rm -f honeypot-logstash-1
sleep 1
docker rm -f honeypot-nginx-2
sleep 1
docker rm -f etcdk

echo ""
echo "Local Docker instances running: "

docker ps

echo ""
echo "$(tput setaf 1) Everything has been destroyed by Malebolgia ;) $(tput sgr 0)"
echo ""
