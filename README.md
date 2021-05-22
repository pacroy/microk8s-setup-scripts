# Microk8s Setup Scripts

Bash script to setup microk8s on Ubuntu 20.04.

## Install microk8s

```sh
./setup.sh
```

## Install ingress-nginx

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n kube-system --set "controller.service.type=NodePort"
```

_Reference: https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/values.yaml_

## Install cert-manager

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set "installCRDs=true"
```
