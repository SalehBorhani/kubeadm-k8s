#!/bin/bash



## Container runtime (containerd) https://github.com/containerd/containerd/blob/main/docs/getting-started.md
wget https://github.com/containerd/containerd/releases/download/v1.7.1/containerd-1.7.1-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.1-linux-amd64.tar.gz

# containerd service 
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

##runc installation
wget https://github.com/opencontainers/runc/releases/download/v1.1.8/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

## CNI plugin
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz

## containerd config
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml
sed -i '/sandbox_image/s/\"registry.k8s.io\/pause:3.6"/\"docker.iranrepo.ir\/kubesphere\/pause:3.9"/' /etc/containerd/config.toml
systemctl restart containerd



# Disable swap
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
swapoff -a
line_number=$(grep -n "swap" /etc/fstab | tail -1 | awk -F: '{print $1}')

if [ -n "$line_number" ]; then 
    sed -i "${line_number}s/^/#/" /etc/fstab
fi
mount -a 


# bridge
modprobe br_netfilter
echo -e "net.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sudo sysctl -p

# install kubeadm kubelet kubectl
apt-get update && apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl




