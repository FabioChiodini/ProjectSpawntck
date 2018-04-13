#create topic
kubectl apply -f serverless/topics/tcfaas-topic.yaml

#create function
kubectl apply -f serverless/functions/tcfaas-function.yaml

#Checks deployment
kubectl get deployment tcfaas

#checks that no pod are started (it's serverless!!)
kubectl get pods
