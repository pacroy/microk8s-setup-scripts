#!/usr/bin/env bash
set -o errexit
set -o pipefail

# Wait until ready
sudo microk8s status --wait-ready

# Check nodes and services
sudo microk8s kubectl get nodes,services

# Enable dns and storage addons
sudo microk8s enable dns storage

# Configure remote access by adding machine public hostname and IP address
sudo nano /var/snap/microk8s/current/certs/csr.conf.template

# Export kubeconfig file
# shellcheck disable=SC2024
sudo microk8s config > ~/admin.config
