#!/bin/bash
set -e

LTS_VERSION=$(pacman -Qe | grep "^linux-lts" | awk '{print $2}')
if [ -z "$LTS_VERSION" ]; then
  echo "Error: linux-lts version not found"
  exit 1
fi

# gpg --keyserver keys.gnupg.net --recv-keys 6AD860EED4598027

# build zfs-utils
rm -rf zfs-utils
git clone https://aur.archlinux.org/zfs-utils.git
pushd zfs-utils

PKGVER=$(grep -oP 'pkgver=\K[0-9.]+' PKGBUILD)
SHA256=$(grep -oP "sha256sums=\('\K[a-f0-9]+(?=')" PKGBUILD)

makepkg --syncdeps --clean --rmdeps --noconfirm --install
popd

# build zfs-linux-lts
rm -rf zfs-linux-lts
git clone https://aur.archlinux.org/zfs-linux-lts.git
pushd zfs-linux-lts

sed -i \
  -e "s/^_zfsver=\"[0-9.]*\"/_zfsver=\"$PKGVER\"/" \
  -e "s/^sha256sums=(\"[a-f0-9]*\")/sha256sums=(\"$SHA256\")/" \
  -e "s/^_kernelver=.*/_kernelver=\"$LTS_VERSION\"/" \
  -e "s/^*kernelver*full=.*/*kernelver*full=\"$LTS_VERSION\"/" \
  -e "s/^_extramodules=.*/_extramodules=\"$LTS_VERSION-lts\"/" \
  PKGBUILD

makepkg --syncdeps --clean --rmdeps --noconfirm
popd
