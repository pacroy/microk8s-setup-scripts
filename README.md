# Microk8s Setup Scripts

![](https://img.shields.io/badge/status-deprecated-red)

:warning: **IMPORTTANT: This project is superseded by [pacroy/microk8s-azure-vm](https://github.com/pacroy/microk8s-azure-vm).** :warning:

Bash script to setup microk8s on Ubuntu 20.04.

## Prerequisites

Create the following Azure resources to deploy an Ubuntu Linux VM behind a load balancer.

### Resource Group

Create a new resource group

### Virtual Network

Create a new virtual network with one subnet with an associated NSG.

- Assign a `/16` address space within [private addresses ranges][]
- Create a subnet with `/24` address range within the assigned VNET space
- Create an NSG and associated with the subnet. Leave the rules as-is, we will configure it later.

[private addresses ranges]: <https://www.ibm.com/docs/en/networkmanager/4.2.0?topic=translation-private-address-ranges>

### Virtual Machine

Create an Ubuntu Linux VM.

- Choose to create `Ubuntu Server 20.04 LTS`
- Size: Standard_B2ms (2 vcpus, 8GiB memory)
- Authentication type: SSH
- Set a username
- SSH public key source: Use existing public key
- Copy your local public SSH key into SSH public key
- Public inbound port: None
- Public IP: None
- NIC network security group: None

### Load Balancer

Create a new load balancer and a public IP.

- Type: Public
- SKU: Standard
- Tier: Regional
- Add a new frontend IP and create a new public IP
- Add a backend pool and add your VM into the list
- Add a new load balancing rule for inbound SSH:
  - Allow TCP:Frontend port:Backend port to the backend pool
  - Create a new health probe with TCP:SSH port
  - TCP reset: Disabled
  - Floating IP: Disabled
  - Outbound SNAT: Use recommended setting
- Add a new outbound rule from the backend pool
  - Protocol: All
  - TCP Reset: Disabled
  - Port allocation: Manually choose number of outbound ports
  - Outbound ports-Choose by: Ports per instance
  - Port per instance: 16384

### Configure NSG and Test SSH

- Add a new inbound rule to allow traffic from source IPs (e.g. your computer-check by `curl ipv4.icanhazip.com`) to the backend SSH port.
- Test SSH connection by `ssh -p <port> <your_ser_ip_or_dns>`

## Install microk8s

```sh
git clone https://github.com/pacroy/microk8s-setup-scripts.git
cd microk8s-setup-scripts
./setup1.sh
./setup2.sh
```

Edit file `/var/snap/microk8s/current/certs/csr.conf.template` by adding VM's public DNS and IP:

```properties
[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
DNS.6 = <your_vm_dns_name>
IP.1 = 127.0.0.1
IP.2 = 10.xxx.xxx.1
IP.3 = <your_vm_public_ip>
#MOREIPS
```

## Remote Access

Generate kube config file

```sh
microk8s config > ~/admin.config
```

Transfer the kube config file to your computer

```sh
scp your_server:~/admin.config ~/admin.config
```

Set the `KUBECONFIG` environment variable and you can start using kubectl

```sh
export KUBECONFIG=~/admin.config
kubectl version
```

### Install ingress-nginx

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n kube-system --set "controller.service.type=NodePort"
```

_Reference: [ingress-nginx/values.yaml at main · kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml)_

### Install cert-manager

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set "installCRDs=true"
```

### Install Let's Encrypt ACME ClusterIssuer

```sh
helm repo add pacroy https://pacroy.github.io/helm-repo
helm repo update
helm install cluster-issuer pacroy/cluster-issuer -n cert-manager --set "email=youremail@address.com"
```

*replace `youremail@address.com` with your email address.

## Setup Attended Upgrades

Ref: [Set up Automatic Security Update (Unattended Upgrades) on Ubuntu](https://www.linuxbabe.com/ubuntu/automatic-security-update-unattended-upgrades-ubuntu)

### Install unattended-upgrades

Update system and install unattended-upgrades

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y unattended-upgrades update-notifier-common
```

### Configure unattended-upgrades

Edit file `/etc/apt/apt.conf.d/50unattended-upgrades` to uncomment and configure these lines:

```properties
# Uncomment and configure these lines
Unattended-Upgrade::Mail "youremail@address.com,someone@somewhere.com";
Unattended-Upgrade::MailReport "on-change";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "00:30";
```

*replace `youremail@address.com` with your email address.

### Enable unattended-upgrades

Edit file `/etc/apt/apt.conf.d/20auto-upgrades` and make sure these lines are in place:

```properties
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

## Enable Email Notification

### Install bsd-mailx and postfix

```bash
sudo apt install -y bsd-mailx postfix libsasl2-modules
```

Select <kbd>Internet Site</kbd> and input your SMTP domain as _system mail name_.

### Configure SMTP Relay

Edit file `/etc/postfix/main.cf`.

Edit the following line:

```properties
relayhost = [smtp.yourhost.com]:25
```

*replace `[smtp.yourhost.com]:25` with your SMTP address and port.

Add the following lines:

```properties
# outbound relay configurations
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = may
header_size_limit = 4096000
```

### Create SMTP passwd File

Create file `/etc/postfix/sasl_passwd` and add the following line:

```text
[smtp.yourhost.com]:25      username:password
```

*replace `[smtp.yourhost.com]:25` with your SMTP address and port.<br />
*replace `username` with your SMTP username.<br />
*replace `password` with your SMTP password.

### Create Hash DB

```bash
sudo postmap /etc/postfix/sasl_passwd
sudo chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
```

### Restart postfix

```bash
sudo systemctl restart postfix
```

### Test Sending Email

```bash
echo "this is a test email." | mailx -r "from@yourhost.com" -s "hello" "youremail@address.com" "someone@somewhere.com"
```

*replace `from@yourhost.com` with an address at your SMTP domain.<br />
*replace `youremail@address.com` with your email address.

## Automatic Restart

Ref: [Schedule shutdown every day on Ubuntu 20.04 - Ask Ubuntu](https://askubuntu.com/questions/1278880/schedule-shutdown-every-day-on-ubuntu-20-04)

Edit crontab using `sudo crontab -e` and add the following line:

```crontab
29 0 * * 0 echo "$(hostname) is restarting..." | mailx -r "from@yourhost.com" -s "$(hostname) is restarting" "youremail@address.com" "someone@somewhere.com" && shutdown -r +1
```
