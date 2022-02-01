#!/bin/bash

PACKAGE="helloworld"
VERSION="0.1"
REVISION="1"
BUILDDIR="$(mktemp -d)/${PACKAGE}_$VERSION-$REVISION"

# Place sources and build package
mkdir -p "$BUILDDIR/usr/src/${PACKAGE}-$VERSION"
mkdir -p "$BUILDDIR/etc"
mkdir -p "$BUILDDIR/DEBIAN"
cp -r /vagrant/src/usr/src/* "$BUILDDIR/usr/src/${PACKAGE}-$VERSION"
cp -r /vagrant/src/etc/* "$BUILDDIR/etc"
cp -r /vagrant/src/DEBIAN/* "$BUILDDIR/DEBIAN"
cd "$BUILDDIR/.."
dpkg-deb --build "${PACKAGE}_$VERSION-$REVISION"

# Install package
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y linux-headers-$(uname -r)
apt-get install -y "./${PACKAGE}_$VERSION-$REVISION.deb"

# Load module and show details about it
modinfo helloworld
cat /proc/modules | grep helloworld
rmmod helloworld
modprobe helloworld
cat /var/log/messages | grep helloworld
