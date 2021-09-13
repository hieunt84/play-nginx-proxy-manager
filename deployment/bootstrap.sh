#!/bin/bash
# Script deploy nginx-proxy-manager with docker

##########################################################################################
# SECTION 1: PREPARE

# update system
yum clean all
yum -y update
sleep 1

# config timezone
timedatectl set-timezone Asia/Ho_Chi_Minh

# disable SELINUX
setenforce 0 
sed -i 's/enforcing/disabled/g' /etc/selinux/config

# disable firewall
systemctl stop firewalld
systemctl disable firewalld

# config hostname
hostnamectl set-hostname proxy

# config file host
cat >> "/etc/hosts" <<END
192.168.1.246 proxy proxy.hit.local
END

##########################################################################################
# SECTION 2: Install  Dependencies
# docker, vmware-tools, git, docker-compose

# install docker

yum -y install yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce

# create servie docker
mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
 "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
 "log-opts": {
 "max-size": "100m"
 },
 "storage-driver": "overlay2",
 "storage-opts": [
   "overlay2.override_kernel_check=true"
 ]
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# install vmware tools
yum -y install open-vm-tools

# install git
yum -y install git

# Install docker-compose
sudo curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#########################################################################################
# SECTION 3: DEPLOY NGINX-PROXY-MANAGER

# clone repo from github
cd ~
git clone https://github.com/hieunt84/play-nginx-proxy-manager.git

# change working directory
cd ./play-nginx-proxy-manager/deployment

# deploy
# docker-compose up -d

# verify
# docker-compose ps

#########################################################################################
# SECTION 4: FINISHED

# config firwall
systemctl start firewalld
systemctl enable firewalld

# notification
echo "next deploy in file doc.md"
echo " Server restart 5s"
sleep 5
reboot