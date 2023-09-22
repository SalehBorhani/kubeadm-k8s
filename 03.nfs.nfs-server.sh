#!/bin/bash
# run this on a dedicated machine for nfs
# run the script with the number of your workers
read -p "Input your number of workers: " num

# nfs server
apt install -y nfs-server

# where to mount
mkdir /data

# adding to exports
for i in $(seq 1 $num); do
read -p "input your worker ip address: " ip
echo "/data $ip(rw,no_subtree_check,no_root_squash)" >> /etc/exports
done


systemctl enable --now nfs-server
systemctl restart nfs-server
exportfs -ar
