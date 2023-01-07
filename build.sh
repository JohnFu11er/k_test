#!/bin/bash

function status_logging() {
    echo $1 >> ./build_output.txt
    sudo wall -n $1
}

#############################
# Basic node configuration

touch build_output.txt

status_logging "starting build"

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

  
status_logging "containerd installed"

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

VERSION=1.24.3-00
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl containerd

sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service

status_logging "base node build complete"

#############################
# Control-node configuration
wget https://docs.projectcalico.org/manifests/calico.yaml

sudo kubeadm init --kubernetes-version v1.24.3
status_logging "kuberenetes build complete"
