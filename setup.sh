#!/usr/bin/env bash
set -o errexit
set -o pipefail

# Update system
sudo apt-get update && sudo apt-get upgrade -y

