#!/bin/bash

LOGGING_FILE=/home/ubuntu/k8s_build_log.txt


function status_logging() {
    log_msg=$1
    echo $log_msg >> $LOGGING_FILE
    sudo wall -n $log_msg
}

#############################
# Basic node configuration

touch $LOGGING_FILE

status_logging "- starting build"

swapoff -a

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

sudo apt-get update 
sudo apt-get install -y containerd

  
status_logging "- containerd installed"




sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
status_logging "- containerd restarted"


sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

VERSION=1.24.9-00
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
status_logging "- kubelet, kubeadm, and kubectl installed"

sudo apt-mark hold kubelet kubeadm kubectl containerd


sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service
status_logging "- base node build complete"

