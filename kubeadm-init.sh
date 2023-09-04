#!/bin/bash

#kubeadm reset
echo y | kubeadm reset
read -p "Enter one of your master ip: " IP
# CNI plugin yaml https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy
# a custom yaml for iranrepo.ir
wget https://raw.githubusercontent.com/SalehBorhani/kubeadm-k8s/main/weave/weave.yaml

# kubeadm
kubeadm init --control-plane-endpoint $IP:6443 --upload-certs --pod-network-cidr 10.0.0.0/16  --image-repository docker.iranrepo.ir/kubesphere --kubernetes-version 1.27.1 

mkdir -p $HOME/.kube
echo yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# apply the weave
kubectl apply -f weave.yaml -n kube-system

# kill it when everything is up 

kubectl get pods -n kube-system -w 
