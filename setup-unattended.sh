#!/usr/bin/env bash
# Ref: https://askubuntu.com/questions/1278880/schedule-shutdown-every-day-on-ubuntu-20-04
set -o errexit
set -o pipefail

# Install unattended-upgrades
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y unattended-upgrades update-notifier-common

# Configure unattended-upgrades
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

# Enable unattended-upgrades
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
