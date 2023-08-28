# kubeadm-k8s scripts

Setting up k8s clusters with `kubeadm`.   
There are three bash scripts for the `master` node setup.     
you can clone your vm and join them to the `master` node.     

# setup master and worker

Setting up master and cloning it for worker usage.

* find more info in [containerd-kubeadm](./containerd-kubeadm.sh) comments.

* the [kubeadm init](./kubeadm-init.sh) proccess and weave as the `network plugin`

* setting [alias](./zsh-alias-comp.sh) and completion for kubeadm and kubectl


# storage for k8s

Fastest way for providing your cluster with storage is `nfs` in this matter.    

make sure your worker nodes have the `nfs-common` package installed (nfs client)   

this [script](./nfs-storage.sh) is for installing nfs on a dedicated server.

run it like this :

```
./nfs-storage.sh <number of your worker nodes>
```
it will ask for the ip address of your worker nodes.       


# nfs provisioner

You can use your nfs server info to create pv manually , but for the easier access to nfs we setup `nfs-provisioner` that automatically provisions pv to pvc.

* you need [helm](https://helm.sh/docs/intro/install/)
* add and install the helm chart 

```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
```
```
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --create-namespace \
  --namespace nfs-provisioner \
  --set nfs.server= <nfs server ip address> \
  --set nfs.path=/data --set storageClass.reclaimPolicy=Retain \
  --set image.repository=salehborhani/nfs-subdir-external-provisioner
```

* you may need to change the chart's image registry or image name (403 problem)  


Now we can easily create pvc and use it for persistence.
