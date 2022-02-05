#!/usr/bin/env bash
set -o errexit
set -o pipefail

# Install bsd-mailx and postfix
sudo apt install -y bsd-mailx postfix libsasl2-modules

# Configure SMTP Relay
sudo nano /etc/postfix/main.cf

# Create SMTP passwd File
sudo nano /etc/postfix/sasl_passwd

# Create Hash DB
sudo postmap /etc/postfix/sasl_passwd
sudo chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

# Restart postfix
sudo systemctl restart postfix

# Test Sending Email
printf "=== Test Sending Email ===\n"
printf "Sender Email  : " && read -r sender
printf "Receiver Email: " && read -r receiver
echo "this is a test email." | mailx -r "$sender" -s "hello" "$receiver"
