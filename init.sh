# CNI plugin yaml https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy
wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

# kubeadm
kubeadm init --pod-network-cidr 10.0.0.0/16  --image-repository docker.iranrepo.ir/kubesphere --kubernetes-version 1.27.1 

mkdir -p $HOME/.kube
echo yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

