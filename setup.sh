#!/usr/bin/env bash
set -o errexit
set -o pipefail

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install microk8s
sudo snap install microk8s --classic --channel=1.21
