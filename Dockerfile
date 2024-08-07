FROM archlinux:base-devel

# makepkg cannot (and should not) be run as root:
RUN useradd -m build && \
    pacman -Syu --noconfirm && \
    pacman -Sy --noconfirm git linux-lts && \
    # Allow build to run stuff as root (to install dependencies):
    echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/build

# Continue execution (and CMD) as build:
USER build
WORKDIR /package

USER root
COPY ./build_packages.sh /usr/local/bin/build_packages.sh
RUN chmod +x /usr/local/bin/build_packages.sh
USER build

CMD ["/usr/local/bin/build_packages.sh"]
