#!/bin/bash

LOGGING_FILE = /home/ubuntu/k8s_build_log.txt


function status_logging() {
    log_msg=$1
    echo $log_msg >> LOGGING_FILE
    sudo wall -n $log_msg
}


#############################
# Control-node configuration
wget https://docs.projectcalico.org/manifests/calico.yaml

sudo kubeadm init --kubernetes-version v1.24.3
status_logging "- control plane node build complete"
