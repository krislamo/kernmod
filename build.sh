#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install build-essential linux-headers-$(uname -r) -y

cd /vagrant
make
modinfo helloworld.ko
insmod helloworld.ko
cat /proc/modules | grep helloworld
rmmod helloworld
cat /var/log/messages | grep helloworld
