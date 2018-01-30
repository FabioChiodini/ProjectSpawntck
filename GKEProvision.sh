gcloud container clusters create delltechdemo123

# It takes a few minutes to do this

kubectl get nodes

kubectl create -f kubefiles/ -R --namespace=default

kubectl get pods,deployments,services,ingress,configmaps


# kubectl delete -f kubefiles/ -R --namespace=default

# gcloud container clusters delete delltechdemo123
