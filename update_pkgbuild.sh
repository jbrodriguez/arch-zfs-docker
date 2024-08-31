#!/bin/bash

# Ensure both parameters are passed
if [ $# -ne 2 ]; then
  echo "Usage: $0 <pkgver> <sha256sum>"
  exit 1
fi

pkgver=$1
sha256sum=$2

# Get the linux-lts version
lts_version=$(pacman -Qe | grep "^linux-lts" | awk '{print $2}')
if [ -z "$lts_version" ]; then
  echo "Error: linux-lts version not found"
  exit 1
fi

full_kernel_version=$lts_version

# Update the PKGBUILD file with the linux-lts version, _zfsver, and sha256sums
sed -i \
  -e "s/^_kernelver=.*/_kernelver=\"$full_kernel_version\"/" \
  -e "s/^*kernelver*full=.*/kernelver*full=\"$full_kernel_version\"/" \
  -e "s/^_extramodules=.*/_extramodules=\"$full_kernel_version-lts\"/" \
  -e "s/^_zfsver=.*/_zfsver=\"$pkgver\"/" \
  -e "s/^sha256sums=.*/sha256sums=('$sha256sum')/" \
  PKGBUILD

echo "PKGBUILD updated with linux-lts version $full_kernel_version, _zfsver $pkgver, and sha256sums $sha256sum"
