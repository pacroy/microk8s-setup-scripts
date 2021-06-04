# Microk8s Setup Scripts

Bash script to setup microk8s on Ubuntu 20.04.

## Configure System

- Update system
- Install python2 (required for LinuxDiagnostic extension)
- Configure custom port for SSH

Run with Custom Script for Linux extension

```sh
apt-get update && apt-get upgrade -y && apt install -y python2 && ln -s /usr/bin/python2 /usr/bin/python && sed -i 's/#Port 22/Port 12345/g' /etc/ssh/sshd_config && systemctl restart sshd
```

*replace `12345` with the port number you want or generate a random one from [here](https://www.random.org/integers/?num=1&min=5001&max=49151&col=5&base=10&format=html&rnd=new).

## Install microk8s

```sh
./setup.sh
```

### Install ingress-nginx

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n kube-system --set "controller.service.type=NodePort"
```

_Reference: https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/values.yaml_

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

```
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

```
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

```
relayhost = [smtp.yourhost.com]:25
```

*replace `[smtp.yourhost.com]:25` with your SMTP address and port.

Add the following lines:

```
# outbound relay configurations
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = may
header_size_limit = 4096000
```

### Create SMTP passwd File

Create file `/etc/postfix/sasl_passwd` and add the following line:

```
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

```
29 0 * * 0 echo "$(hostname) is restarting..." | mailx -r "from@yourhost.com" -s "$(hostname) is restarting" "youremail@address.com" "someone@somewhere.com" && shutdown -r +1
```
