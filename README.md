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
  --set image.repository=docker.arvancloud.ir/salehborhani/nfs-subdir-external-provisioner \
  --set storageClass.defaultClass=true \
  --version 4.0.18
```

* you may need to change the chart's image registry or image name (403 problem)  


Now we can easily create pvc and use it for persistence.

# Nginx ingress controller

there is a helm chart for deploying this.   

Install with setting it as the default controller and `30100` port for http and `30200` port for https

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm upgrade --install ingress-main ingress-nginx/ingress-nginx \
--set controller.ingressClassResource.default=true \
--set controller.service.nodePorts.http="30100" \
--set controller.service.nodePorts.https="30200" \
--set controller.kind="DaemonSet" \
--namespace ingress-nginx --create-namespace  --version 4.8.0
```
# Prometheus-stack 
Install prom-stack with `prom-operator` password:
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts


helm install prom prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace \
--set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
--set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
--set grafana.image.repository=docker.arvancloud.ir/grafana/grafana  --version 49.0.0
```
# Metrics-server
For metrics-server you have to apply the below helm charts:
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server \
--set-string "defaultArgs[0]=--cert-dir=/tmp" \
--set-string "defaultArgs[1]=--kubelet-preferred-address-types=InternalIP\,ExternalIP\,Hostname" \
--set-string "defaultArgs[2]=--kubelet-use-node-status-port" \
--set-string "defaultArgs[3]=--metric-resolution=15s" \
--set-string "defaultArgs[4]=--kubelet-insecure-tls" --version 3.11.0

```

# Cached images
(Ingress)    

* `registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20230407` -> `arpjoker/kube-webhook-certgen:v20230407` (remove digest)

* `registry.k8s.io/ingress-nginx/controller:v1.9.0` -> `arpjoker/controller:v1.9.0` (remove digest)

(Prometheus)
* `registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0` -> `arpjoker/kube-webhook-certgen:v20231011-8b53cabe0` (no digest , check to be sure)

* `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.9.2` -> `arpjoker/kube-state-metrics:v2.9.2` (no digest)

* `registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6` -> `arpjoker/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6` (no digest)

(Metric Server)    

* `registry.k8s.io/metrics-server/metrics-server:v0.6.4` -> `arpjoker/metrics-server:v0.6.4` (no digest)
