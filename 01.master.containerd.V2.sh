#!/bin/bash

## change directory to /tmp
cd /tmp
## Container runtime (containerd) https://github.com/containerd/containerd/blob/main/docs/getting-started.md

wget https://github.com/containerd/containerd/releases/download/v1.7.1/containerd-1.7.1-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.1-linux-amd64.tar.gz

# containerd service 
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /etc/systemd/system/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

##runc installation
wget https://github.com/opencontainers/runc/releases/download/v1.1.8/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

## CNI plugin
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz

## containerd config
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd



# Disable swap
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
swapoff -a
line_number=$(grep -n "swap" /etc/fstab | tail -1 | awk -F: '{print $1}')

if [ -n "$line_number" ]; then 
    sed -i "${line_number}s/^/#/" /etc/fstab
fi
mount -a 


# bridge
sudo modprobe br_netfilter
echo -e "net.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sudo sysctl -p

# backup dns setup & Set Shecan DNS
cp /etc/resolv.conf /etc/resolv.conf.bak
# added at the end
sudo sed -i 's/nameserver .*/nameserver 178.22.122.100/' /etc/resolv.conf

# install kubeadm kubelet kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubeadm


# pull images with kubeadm
kubeadm config images pull  --image-repository docker.arvancloud.ir/kubesphere --kubernetes-version 1.27.1 


# Changing the sandbox image
sudo sed -i '/sandbox_image/s/\"registry.k8s.io\/pause:3.8"/\"docker.arvancloud.ir\/kubesphere\/pause:3.9"/' /etc/containerd/config.toml
sudo systemctl restart containerd


# installing nfs-client (used in workers , we want to clone the vm so why not install it)
apt install -y nfs-common

#sudo sed -i 's/nameserver .*/nameserver 178.22.122.100/' /etc/resolv.conf
