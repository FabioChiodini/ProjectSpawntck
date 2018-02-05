kubectl delete -f kubefiles/ -R --namespace=default

gcloud container clusters delete delltechdemo123 --quiet

#Delete local docker containers

#Kill local containers
echo ""
echo "$(tput setaf 1) Destroying Local Containers $(tput sgr 0)"
echo ""
docker rm -f etcd-browserk$instidk
sleep 1
docker rm -f honeypot-i
sleep 1
docker rm -f etcdk
