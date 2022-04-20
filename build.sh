#!/bin/bash

# Initial variables
PACKAGE="helloworld"
VERSION="0.1"
REVISION="1"
SRCDIR="/vagrant/src"
SCRATCH="/vagrant/scratch"
OUTDIR="$SCRATCH"
TEMPDIR="$(mktemp -d)"
INSTALL=0
BUILDDIR="$TEMPDIR/${PACKAGE}_$VERSION-$REVISION"

# Test for distribution of GNU/Linux
# 0 = unknown
# 1 = debian
# 2 = rocky/centos/rhel
function check_distro {
  if [ -f /etc/debian_version ]; then echo 1
  elif [ -f /etc/rocky-release ] || [ -f /etc/centos-release ]; then echo 2
  else echo 0
  fi
}

# Build debian package
function build_deb {
  [ $INSTALL -eq 1 ] && debian_headers
  mkdir -p "$BUILDDIR/usr/src/${PACKAGE}-$VERSION"
  mkdir -p "$BUILDDIR/etc"
  mkdir -p "$BUILDDIR/DEBIAN"
  cp -r $SRCDIR/usr/src/* "$BUILDDIR/usr/src/${PACKAGE}-$VERSION"
  cp -r $SRCDIR/etc/* "$BUILDDIR/etc"
  cp -r $SRCDIR/DEBIAN/* "$BUILDDIR/DEBIAN"
  cd "$TEMPDIR"
  dpkg-deb --build "${PACKAGE}_$VERSION-$REVISION"
}

# Build redhat package
function build_rpm {
  [ $INSTALL -eq 1 ] && rhel_headers
}

# Display details on module
function info_mod {
  modinfo "$PACKAGE"
  cat /proc/modules | grep "$PACKAGE"
  rmmod "$PACKAGE"
  modprobe "$PACKAGE"
  cat /var/log/messages | grep "$PACKAGE"
}

# Install Linux headers for current debian kernel
function debian_headers {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y linux-headers-$(uname -r)
}

# Install Linux headers for current rhel kernel
function rhel_headers {
  VERSION="$(uname -r | rev | cut -d '.' -f 2- | rev)"
  yum install -y kernel-headers-"$VERSION"
}

# Find GNU/Linux distribution
set -x
DISTRO="$(check_distro)"
if [ $DISTRO -eq 0 ]; then
  echo "ERROR: GNU/Linux distribution not detected"
  exit -1
fi

# Build and install helloworld module or module(s) in $SCRATCH
if [ ! -z "$(ls -Al $SCRATCH | grep -e ^d)" ]; then
  cd "$SCRATCH"
  for d in */ ; do
    if [ -f "$(basename $d)/override.sh" ]; then
      SRCDIR="$(pwd)/$(basename $d)"
      . "$(basename $d)/override.sh"
      [ $DISTRO -eq 1 ] && build_deb
      [ $DISTRO -eq 2 ] && build_rpm
      if [ $INSTALL -eq 1 ]; then
        apt-get install -y "./${PACKAGE}_$VERSION-$REVISION.deb"
        info_mod
      fi
      cp "./${PACKAGE}_$VERSION-$REVISION.deb" \
         "$OUTDIR/${PACKAGE}_$VERSION-$REVISION-$(date +%s).deb"
    fi
  done
else
  INSTALL=1
  if [ $DISTRO -eq 1 ]; then
    build_deb
    apt-get install -y "./${PACKAGE}_$VERSION-$REVISION.deb"
  elif [ $DISTRO -eq 2 ]; then
    build_rpm
    echo "end of debug: exiting..."
    exit 0
    yum install -y "./${PACKAGE}_$VERSION-$REVISION.rpm"
  fi
fi
