#!/usr/bin/env bash
set -o errexit
set -o pipefail

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install microk8s
sudo snap install microk8s --classic --channel=1.21

# Configure permission
sudo usermod -a -G microk8s "$USER"
sudo chown -f -R "$USER" ~/.kube
newgrp microk8s
microk8s status --wait-ready

# Check nodes and services
microk8s kubectl get nodes,services

# Enable dns and storage addons
microk8s enable dns storage

# Configure remote access by adding machine public hostname and IP address
nano /var/snap/microk8s/current/certs/csr.conf.template

# Export kubeconfig file
microk8s config > ~/admin.config
