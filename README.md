# Kubernetes Demonstration

The following is a [Kubernetes](https://kubernetes.io/) stack demo, that integrates [Istio](https://istio.io/), [Helm](https://helm.sh/), [Keel](https://keel.sh/), and [Sensu](https://sensu.io) on top of [minikube](https://minikube.sigs.k8s.io/) on Mac OS.

## Install Tooling

```bash
brew install kubernetes-cli kubernetes-helm kubectx
brew cask install minikube
minikube config set vm-driver virtualbox
minikube config set memory 8192
minikube config set cpus 4
minikube start --extra-config=kubelet.authentication-token-webhook=true
minikube addons enable ingress
```

## Install Istio.io

```bash
ISTIO_VERSION=1.3.0
curl -L https://git.io/getLatestIstio | sh -
INSTALL_DIR=istio-$ISTIO_VERSION/install/kubernetes/helm
kubectl apply -f $INSTALL_DIR/helm-service-account.yaml
kubectl apply -f k8s/tiller/
helm upgrade -i istio-init $INSTALL_DIR/istio-init --namespace istio-system
helm upgrade -i istio $INSTALL_DIR/istio --namespace istio-system \
  --values $INSTALL_DIR/istio/values-istio-demo.yaml
kubectl label namespace default istio-injection=enabled
```

## Install metrics-server

```bash
helm upgrade -i metrics-server stable/metrics-server --namespace kube-system \
  --set args="{--logtostderr,--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP\,ExternalIP\,Hostname}"
```

## Install Keel

```bash
helm repo add keel-charts https://charts.keel.sh
helm repo update
helm upgrade -i keel keel-charts/keel --namespace=kube-system
```

## Install Sensu

```bash
git clone https://github.com/kubernetes/kube-state-metrics
kubectl apply -f kube-state-metrics/kubernetes/
kubectl create namespace sensu-system
kubectl apply -f k8s/sensu/
sudo -- sh -c "echo '$(minikube ip) sensu.local webui.sensu.local' >> /etc/hosts"

SENSUCTL_PACKAGE=sensu-go_5.13.1_darwin_amd64.tar.gz
curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.13.1/$SENSUCTL_PACKAGE
tar -xvf $SENSUCTL_PACKAGE sensuctl
sudo mv sensuctl /usr/local/bin/
rm $SENSUCTL_PACKAGE

sensuctl configure
? Sensu Backend URL: http://sensu.local
? Username: admin
? Password: P@ssw0rd!
? Namespace: default
? Preferred output format: tabular
```

Accessing Sensu:
```
http://webui.sensu.local
Username: admin
Password: P@ssw0rd!
```

## Build Docker Images

```bash
docker build -t k776/users-service:latest users
docker push k776/users-service:latest

docker build -t k776/accounts-service:latest accounts
docker push k776/accounts-service:latest
```

## Install/Update Resources

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
kubectl top pods
minikube dashboard
./istio-*/bin/istioctl dashboard grafana
./istio-*/bin/istioctl dashboard jaeger
./istio-*/bin/istioctl dashboard kiali
./istio-*/bin/istioctl dashboard prometheus
```
