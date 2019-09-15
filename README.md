# Kubernetes Demonstration

The following is a [Kubernetes](https://kubernetes.io/) stack demo, that integrates [Istio](https://istio.io/), [Helm](https://helm.sh/), and [Keel](https://keel.sh/) on top of [minikube](https://minikube.sigs.k8s.io/) on Mac OS.

## Tooling

```bash
brew install kubernetes-cli kubernetes-helm kubectx
brew cask install minikube
minikube config set memory 8192
minikube config set cpus 4
minikube start
```

## Build Services

```bash
docker build -t k776/users-service:latest users
docker push k776/users-service:latest

docker build -t k776/accounts-service:latest accounts
docker push k776/accounts-service:latest
```

## Install Istio.io

```bash
ISTIO_VERSION=1.3.0
curl -L https://git.io/getLatestIstio | sh -
INSTALL_DIR=istio-$ISTIO_VERSION/install/kubernetes/helm
kubectl apply -f $INSTALL_DIR/helm-service-account.yaml
helm init --upgrade --service-account tiller
helm upgrade -i istio-init $INSTALL_DIR/istio-init --namespace istio-system
helm upgrade -i istio $INSTALL_DIR/istio --namespace istio-system \
  --values $INSTALL_DIR/istio/values-istio-demo.yaml
kubectl label namespace default istio-injection=enabled
```

## Install Keel

```bash
helm repo add keel-charts https://charts.keel.sh
helm repo update
helm upgrade -i keel keel-charts/keel --namespace=kube-system
```

## Install/Update Services

```bash
helm upgrade -i users-service k8s/users
helm upgrade -i accounts-service k8s/accounts
kubectl apply -f k8s/istio/
```

## Accessing Services

Through Proxy:
```bash
minikube service users-service --url
minikube service accounts-service --url
```

Through Istio:
```bash
export INGRESS_HOST=$(minikube ip)
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
echo http://$INGRESS_HOST:$INGRESS_PORT
```

## Helpful Commands

```bash
minikube dashboard
./istio-*/bin/istioctl dashboard grafana
./istio-*/bin/istioctl dashboard jaeger
./istio-*/bin/istioctl dashboard kiali
./istio-*/bin/istioctl dashboard prometheus
```
