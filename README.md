# Kubernetes Demonstration

The following is a Kubernetes stack demo, that integrates Istio, Helm, and Keel on top of minikube on Mac OS.

## Tooling

```
brew install kubernetes-cli kubernetes-helm kubectx
brew cask install minikube
minikube config set memory 8192
minikube config set cpus 4
minikube start
```

## Build Services

```
docker build -t k776/users-service:0.0.1 users
docker push k776/users-service:0.0.1

docker build -t k776/accounts-service:0.0.1 accounts
docker push k776/accounts-service:0.0.1
```

# Install Istio.io

```
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.5 sh -
INSTALL_DIR=istio-$ISTIO_VERSION/install/kubernetes/helm
kubectl apply -f $INSTALL_DIR/helm-service-account.yaml
helm init --service-account tiller
helm install $INSTALL_DIR/istio-init --name istio-init --namespace istio-system
helm install $INSTALL_DIR/istio --name istio --namespace istio-system \
  --values $INSTALL_DIR/istio/values-istio-demo.yaml
kubectl label namespace default istio-injection=enabled
```

# Install Keel

```
helm repo add keel-charts https://charts.keel.sh
helm repo update
helm upgrade --install keel --namespace=kube-system keel-charts/keel
```

# Install/Update Services

```
helm upgrade --install users-service k8s/users
helm upgrade --install accounts-service k8s/accounts
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
