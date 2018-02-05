gcloud container clusters create delltechdemo123

#Currently using v1.7.12-gke.0

# It takes a few minutes to do this

kubectl get nodes

kubectl create -f kubefiles/ -R --namespace=default

kubectl get pods,deployments,services,ingress,configmaps

#After getting the ingress IPs it takes a few minutes for the services to be visible on the external ip

# kubectl delete -f kubefiles/ -R --namespace=default

# gcloud container clusters delete delltechdemo123
