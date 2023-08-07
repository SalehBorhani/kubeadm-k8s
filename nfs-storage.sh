#!/bin/bash
# run the script with the number of your workers
num=$1

# nfs server
apt install -y nfs-server

# where to mount
mkdir /data

# adding to exports
for i in $(seq 1 $num); do
read -p "input your worker ip address: " ip
echo "/data $ip(rw,no_subtree_check,no_root_squash)" >> ./ali
done


systemctl enable --now nfs-server
systemctl restart nfs-server
exportfs -ar