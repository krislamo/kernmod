#!/bin/bash

VERSION="0.1"

# Install build prerequisites
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y dkms build-essential linux-headers-$(uname -r)

# Place source and configuration files on the system
cd /vagrant
mkdir /usr/src/helloworld-$VERSION
cp Makefile /usr/src/helloworld-$VERSION/Makefile
cp helloworld.c /usr/src/helloworld-$VERSION/helloworld.c
cp dkms.conf /usr/src/helloworld-$VERSION/dkms.conf
cp helloworld.conf /etc/modules-load.d/helloworld.conf

# Build and install kernel module with DKMS
dkms add -m helloworld -v $VERSION
dkms build -m helloworld -v $VERSION
dkms install -m helloworld -v $VERSION

# Load module and show details about it
modprobe helloworld
modinfo helloworld
cat /proc/modules | grep helloworld
rmmod helloworld
cat /var/log/messages | grep helloworld
