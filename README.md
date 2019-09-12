# Microservices Demo

The following is a minimally viable microservices demonstration using best practices.

## Tooling

```
brew install kubernetes-cli kubernetes-helm kubectx
brew cask install minikube
minikube config set memory 8192
minikube config set cpus 4
minikube start
eval $(minikube docker-env)
```

## Build Services

```
docker build -t microservice_demo_users users
docker build -t microservice_demo_accounts accounts
```

# Install Istio.io

```
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.5 sh -
kubectl apply -f istio-1.2.5/install/kubernetes/helm/helm-service-account.yaml
helm init --service-account tiller
helm install istio-1.2.5/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
helm install istio-1.2.5/install/kubernetes/helm/istio --name istio --namespace istio-system \
  --values istio-1.2.5/install/kubernetes/helm/istio/values-istio-demo.yaml
kubectl label namespace default istio-injection=enabled
```

# Install Services

```
helm install k8s/users --name users-service
helm install k8s/accounts --name accounts-service
kubectl apply -f k8s/istio/
```

# Update Services

```
helm upgrade users-service k8s/users
helm upgrade accounts-service k8s/accounts
kubectl apply -f k8s/istio/
```

# Accessing Services

Through Proxy:
```
minikube service users-service --url
minikube service accounts-service --url
```

Through Istio:
```
export INGRESS_HOST=$(minikube ip)
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
echo http://$INGRESS_HOST:$INGRESS_PORT
```

# Helpful Commands

```
minikube dashboard

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090
open http://localhost:9090

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000
open http://localhost:3000
```
