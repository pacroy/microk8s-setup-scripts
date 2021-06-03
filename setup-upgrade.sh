#!/usr/bin/env bash
# Ref: https://www.linuxbabe.com/ubuntu/automatic-security-update-unattended-upgrades-ubuntu
set -o errexit
set -o pipefail

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install unattended-upgrades
sudo apt install -y unattended-upgrades update-notifier-common

# Edit configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

# Uncomment and configure these lines
# Unattended-Upgrade::Mail "youremail@address.com";
# Unattended-Upgrade::MailReport "on-change";
# Unattended-Upgrade::Remove-Unused-Dependencies "true";
# Unattended-Upgrade::Automatic-Reboot "true";
# Unattended-Upgrade::Automatic-Reboot-Time "00:30";

# Enable
sudo nano /etc/apt/apt.conf.d/20auto-upgrades

# Make sure these lines are in the file
# APT::Periodic::Update-Package-Lists "1";
# APT::Periodic::Unattended-Upgrade "1";

# Enable email notification
sudo apt install -y bsd-mailx postfix libsasl2-modules

# Configure SMTP relay
sudo nano /etc/postfix/main.cf

# Edit the following line
# relayhost = [smtp.yourhost.com]:25

# Add the following lines
# outbound relay configurations
# smtp_sasl_auth_enable = yes
# smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
# smtp_sasl_security_options = noanonymous
# smtp_tls_security_level = may
# header_size_limit = 4096000

# Create SMTP passwd
sudo nano /etc/postfix/sasl_passwd

# Add the following line
# [smtp.yourhost.com]:25      username:password

# Create corresponding hash db file
sudo postmap /etc/postfix/sasl_passwd
sudo chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

# Restart postfix
sudo systemctl restart postfix

# Test sending email
echo "this is a test email." | mailx -r "from@yourhost.com" -s hello "youremail@address.com"
