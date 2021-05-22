# Microk8s Setup Scripts

Bash script to setup microk8s on Ubuntu 20.04.

## Configure SSH

```sh
sed -i 's/#Port 22/Port 15930/g' /etc/ssh/sshd_config && systemctl restart sshd
```

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

## Install Let's Encrypt ACME ClusterIssuer

```sh
helm repo add pacroy https://pacroy.github.io/helm-repo
helm repo update
helm install cluster-issuer pacroy/cluster-issuer -n cert-manager --set "email=youremail@domain.com"
```
