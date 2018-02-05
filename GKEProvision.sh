gcloud container clusters create delltechdemo123

#Currently using v1.7.12-gke.0

# It takes a few minutes to do this

kubectl get nodes

kubectl create -f kubefiles/ -R --namespace=default

kubectl get pods,deployments,services,ingress,configmaps

#After getting the ingress IPs it takes a few minutes for the services to be visible on the external ip


publicipKibana=$(kubectl get ing/all-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")

publicipelastic=$(kubectl get ing/elasticsearch-ingress --namespace=default -o jsonpath="{.status.loadBalancer.ingress[*].ip}")


# Kubernetes Setup

kubernetescontext=$(kubectl config view -o jsonpath="{.current-context}")

kubcluster=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "gke_tactile-phalanx-189106_us-central1-a_delltechdemo123")].cluster.server}')
# kubectl delete -f kubefiles/ -R --namespace=default

# gcloud container clusters delete delltechdemo123
