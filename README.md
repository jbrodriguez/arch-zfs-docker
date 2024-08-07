# introduction

i needed a way to build my own zfs-linux-lts and zfs-utils, so came up with this solution

[check out the blog article behind it](https://jbrio.net/posts/5-ways-archlinux-zfs/)

## purpose

this docker will build

- zfs-utils
- zfs-linux-lts

against the latest available linux-lts kernel

## usage

- clone/download this repo to your system
- `docker build --tag archbuild .`
- `docker run -i -t --rm -v ~/tmp/zfs:/package archbuild`

will create a zfs-linux-lts & zfs-utils below ~/tmp/zfs
