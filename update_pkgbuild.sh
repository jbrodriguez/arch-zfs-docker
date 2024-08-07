#!/bin/bash

lts_version=$(pacman -Qe | grep "^linux-lts" | awk '{print $2}')
if [ -z "$lts_version" ]; then
  echo "Error: linux-lts version not found"
  exit 1
fi

full_kernel_version=$lts_version

sed -i \
  -e "s/^_kernelver=.*/_kernelver=\"$full_kernel_version\"/" \
  -e "s/^*kernelver*full=.*/*kernelver*full=\"$full_kernel_version\"/" \
  -e "s/^_extramodules=.*/_extramodules=\"$full_kernel_version-lts\"/" \
  PKGBUILD

echo "PKGBUILD updated with linux-lts version $full_kernel_version"
