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

# Build debian package
function build_deb {
  [ $INSTALL -eq 1 ] && install_headers
  mkdir -p "$BUILDDIR/usr/src/${PACKAGE}-$VERSION"
  mkdir -p "$BUILDDIR/etc"
  mkdir -p "$BUILDDIR/DEBIAN"
  cp -r $SRCDIR/usr/src/* "$BUILDDIR/usr/src/${PACKAGE}-$VERSION"
  cp -r $SRCDIR/etc/* "$BUILDDIR/etc"
  cp -r $SRCDIR/DEBIAN/* "$BUILDDIR/DEBIAN"
  cd "$TEMPDIR"
  dpkg-deb --build "${PACKAGE}_$VERSION-$REVISION"
}

# Display details on module
function info_mod {
  modinfo "$PACKAGE"
  cat /proc/modules | grep "$PACKAGE"
  rmmod "$PACKAGE"
  modprobe "$PACKAGE"
  cat /var/log/messages | grep "$PACKAGE"
}

# Install Linux headers for current kernel
function install_headers {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y linux-headers-$(uname -r)
}

# Build and install helloworld module or module(s) in $SCRATCH
set -x
if [ ! -z "$(ls -Al /vagrant/scratch/ | grep -e ^d)" ]; then
  cd "$SCRATCH"
  for d in */ ; do
    if [ -f "$(basename $d)/override.sh" ]; then
      SRCDIR="$(pwd)/$(basename $d)"
      . "$(basename $d)/override.sh"
      build_deb
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
  build_deb
  apt-get install -y "./${PACKAGE}_$VERSION-$REVISION.deb"
  info_mod
fi
