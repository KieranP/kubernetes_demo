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
minikube tunnel &
```

## Install hosts

```bash
export INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
sudo -- sh -c "echo '$INGRESS_IP users.svc accounts.svc' >> /etc/hosts"
sudo -- sh -c "echo '$INGRESS_IP api.sensu ui.sensu' >> /etc/hosts"
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

SENSUCTL_PACKAGE=sensu-go_5.13.1_darwin_amd64.tar.gz
curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.13.1/$SENSUCTL_PACKAGE
tar -xvf $SENSUCTL_PACKAGE sensuctl
sudo mv sensuctl /usr/local/bin/
rm $SENSUCTL_PACKAGE

sensuctl configure
? Sensu Backend URL: http://api.sensu
? Username: admin
? Password: P@ssw0rd!
? Namespace: default
? Preferred output format: tabular
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

(make sure 'minikube tunnel' is running and /etc/hosts points to the right IP)

* http://users.svc
* http://accounts.svc
* http://api.sensu
* http://ui.sensu
 * Username: admin
 * Password: P@ssw0rd!

## Helpful Commands

```bash
kubectl top pods
minikube dashboard
./istio-*/bin/istioctl dashboard grafana
./istio-*/bin/istioctl dashboard jaeger
./istio-*/bin/istioctl dashboard kiali
./istio-*/bin/istioctl dashboard prometheus
```
