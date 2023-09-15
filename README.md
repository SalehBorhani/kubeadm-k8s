# kubeadm-k8s scripts

Setting up k8s clusters with `kubeadm`.   
There are three bash scripts for the `master` node setup.     
you can clone your vm and join them to the `master` node.     

# setup master and worker

Setting up master and cloning it for worker usage.

* find more info in [containerd-installation](./01.master.containerd.sh) comments.

* the [kubeadm init](./02.master.kubeadm-init.sh) proccess and weave as the `network plugin`

* setting [alias](./04.master.zsh-completion.sh) and completion for kubeadm and kubectl

* nfs server [setup](./03.nfs.nfs-server.sh) and [helm](./05.master.helm-install.sh) installation  

# storage for k8s

Fastest way for providing your cluster with storage is `nfs` in this matter.    

make sure your worker nodes have the `nfs-common` package installed (nfs client)   

this [script](./nfs-storage.sh) is for installing nfs on a dedicated server.

run it like this :

```
./03.nfs.nfs-server.sh <number of your worker nodes>
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
  --set image.repository=docker.iranrepo.ir/salehborhani/nfs-subdir-external-provisioner \
  --set storageClass.defaultClass=true
```

* you may need to change the chart's image registry or image name (403 problem)  


Now we can easily create pvc and use it for persistence.

# Nginx ingress controller

there is a helm chart for deploying this.   

Install with setting it as the default controller and `30100` port for http and `30200` port for https

```
helm upgrade --install ingress-main ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--set controller.ingressClassResource.default=true \
--set controller.service.nodePorts.http="30100" \
--set controller.service.nodePorts.https="30200" \
--set controller.image.registry="docker.iranrepo.ir" \
--set controller.kind="DaemonSet" \
--namespace ingress-nginx --create-namespace
```

# metrics-server
For metrics-server you have to apply the below helm charts:
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
```
```
helm upgrade --install metrics-server metrics-server/metrics-server \
--set image.repository=docker.iranrepo.ir/metrics-server/metrics-server
```
Also you should add the following option to the `defaultArgs` section in `values.yml`:
```
--kubelet-insecure-tls
```
