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
helm install istio-1.2.5/install/kubernetes/helm/istio --name istio --namespace istio-system
kubectl label namespace default istio-injection=enabled
```

# Deploy Services

```
kubectl apply -f users/deployment.yaml
kubectl apply -f accounts/deployment.yaml
```

# Accessing Services

```
minikube service users-service
minikube service accounts-service
```
