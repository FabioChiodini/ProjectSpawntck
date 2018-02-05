kubectl delete -f kubefiles/ -R --namespace=default

gcloud container clusters delete delltechdemo123 --quiet

#Delete local docker containers

#Kill local containers
echo ""
echo "$(tput setaf 1) Destroying Local Containers $(tput sgr 0)"
echo ""
docker rm -f ConsulDynDNS
sleep 1
docker rm -f receiverK
sleep 1
docker rm -f etcdk
