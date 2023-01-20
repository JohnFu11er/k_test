#!/bin/bash

LOGGING_FILE = /home/ubuntu/k8s_build_log.txt


function status_logging() {
    log_msg=$1
    echo $log_msg >> LOGGING_FILE
    sudo wall -n $log_msg
}


#############################
# Control-node configuration
sudo wget https://docs.projectcalico.org/manifests/calico.yaml

sudo kubeadm init --kubernetes-version v1.24.9
status_logging "- control plane node build complete"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
status_logging "- configured API server access"

kubectl apply -f calico.yaml
status_logging "deployed yaml file for the pod network"
