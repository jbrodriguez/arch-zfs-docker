FROM archlinux:base-devel

# makepkg cannot (and should not) be run as root:
RUN useradd -m build && \
    # pacman -Syu --noconfirm && \
    pacman -Sy --noconfirm git linux-lts && \
    pacman -Syu --noconfirm && \
    # Allow build to run stuff as root (to install dependencies):
    echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/build

# Continue execution (and CMD) as build:
USER build
WORKDIR /home/build

# Build the package
WORKDIR /package

USER root

# Create and add the update script using EOF notation
COPY ./update_pkgbuild.sh /usr/local/bin/update_pkgbuild.sh

RUN chmod +x /usr/local/bin/update_pkgbuild.sh
USER build

# Clone the repository, update PKGBUILD, and build package
CMD gpg --keyserver keys.gnupg.net --recv-keys 6AD860EED4598027 && \
    rm -rf zfs-utils && \
    git clone https://aur.archlinux.org/zfs-utils.git && \
    pushd zfs-utils && \
    # makepkg --install --syncdeps --clean --rmdeps --noconfirm && \
    makepkg --syncdeps --clean --rmdeps --noconfirm && \
    popd && \
    rm -rf zfs-linux-lts && \
    git clone https://aur.archlinux.org/zfs-linux-lts.git && \
    pushd zfs-linux-lts && \
    PKGVER=$(grep "^pkgver=" ../zfs-utils/PKGBUILD | awk -F'=' '{print $2}') && \
    SHA256SUM=$(grep "^sha256sums=" ../zfs-utils/PKGBUILD | awk -F"'" '{print $2}') && \
    /usr/local/bin/update_pkgbuild.sh "$PKGVER" "$SHA256SUM" && \
    makepkg --syncdeps --clean --rmdeps --noconfirm && \
    popd

