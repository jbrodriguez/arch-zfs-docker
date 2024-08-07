FROM archlinux:base-devel

# makepkg cannot (and should not) be run as root:
RUN useradd -m build && \
    pacman -Syu --noconfirm && \
    pacman -Sy --noconfirm git linux-lts && \
    # Allow build to run stuff as root (to install dependencies):
    echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/build

RUN echo -e "\n[archzfs]\nServer = https://archzfs.com/\$repo/\$arch" >> /etc/pacman.conf && \
    pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76 && \
    pacman-key --init && \
    pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76 && \
    pacman -Syu --noconfirm && \
    pacman --sync --noconfirm --noprogressbar --quiet zfs-utils

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

# RUN gpg --keyserver keys.gnupg.net --recv-keys 6AD860EED4598027

# Clone the repository, update PKGBUILD, and build package
CMD gpg --keyserver keys.gnupg.net --recv-keys 6AD860EED4598027 && \
    rm -rf zfs-utils && \
    git clone https://aur.archlinux.org/zfs-utils.git && \
    pushd zfs-utils && \
    makepkg --syncdeps --clean --rmdeps --noconfirm && \
    popd && \
    rm -rf zfs-linux-lts && \
    git clone https://aur.archlinux.org/zfs-linux-lts.git && \
    pushd zfs-linux-lts && \
    /usr/local/bin/update_pkgbuild.sh && \
    makepkg --syncdeps --clean --rmdeps --noconfirm && \
    popd

#CMD ["makepkg", "--syncdeps", "--clean", "--rmdeps", "--noconfirm"]
#CMD ["/bin/bash"]
