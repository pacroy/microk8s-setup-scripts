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
