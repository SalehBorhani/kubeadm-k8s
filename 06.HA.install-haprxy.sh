#!/bin/bash

sudo apt install --no-install-recommends software-properties-common -y

sudo add-apt-repository ppa:vbernat/haproxy-2.4 -y

sudo apt install haproxy=2.4.\* -y

haproxy -v 

# check ha config file

#haproxy -c -f haproxy-loadbalancer.cfg