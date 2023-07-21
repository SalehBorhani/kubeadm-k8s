#!/bin/bash


# CNI plugin yaml https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy
# a custom yaml for iranrepo.ir
wget https://github.com/SalehBorhani/kubeadm-k8s/blob/main/weave/weave.yaml

# kubeadm
kubeadm init --pod-network-cidr 10.0.0.0/16  --image-repository docker.iranrepo.ir/kubesphere --kubernetes-version 1.27.1 

mkdir -p $HOME/.kube
echo yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# apply the weave
kubectl apply -f weave.yaml

# kill it when everything is up 

kubectl get pods -n kube-system -w 