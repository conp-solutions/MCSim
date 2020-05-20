# Norbert Manthey, 2020
#
# This Dockerfile sets up an Ubuntu 20.04, where tools that are compiled within
# a container that is based on this Dockerfile will be linked against a modified
# libc.a file, which comes with the transparent huge page changes that allow to
# use huge pages in the binary by seeting the environment variable
# GLIBC_THP_ALWAYS to an arbitrary value.
#
# This dockerfile installs common build dependencies to be able to build some
# tools out of the box.

FROM ubuntu:20.04

RUN apt-get update && apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils \
        automake \
        build-essential \
        g++ \
        gcc \
        git \
        make \
        software-properties-common \
        zlib1g-dev

# Modify docker glibc

# Install modified glibc 2.23
# Get dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install autoconf \
    bison \
    dpkg-dev \
    fakeroot \
    gawk \
    gettext \
    perl \
    systemtap-sdt-dev \
    texi2html \
    texinfo \
    wget

# Get dependencies for glibc build
RUN apt-get -y install libaudit-dev \
    libcap-dev \
    libselinux1-dev

RUN mkdir /opt/thp-glibc
RUN git clone https://github.com/conp-solutions/thp.git /opt/thp-glibc/thp

# Enable sources in repositories
RUN sed -i 's:^# deb-src :deb-src :g' /etc/apt/sources.list && apt-get update

# Get glibc, and apply Ubuntu 20.04 patches
RUN cd /opt/thp-glibc && \
    apt-get source glibc-source && \
    mkdir -p /opt/thp-glibc/glibc-2.31/build

# Add THP (v1) patches
RUN cd /opt/thp-glibc/glibc-2.31 && \
    patch -p1 < /opt/thp-glibc/thp/THP-v1/v1-0001-malloc-support-transparent-huge-pages.patch && \
    patch -p1 < /opt/thp-glibc/thp/THP-v1/v1-0002-malloc-improve-THP-effectiveness.patch

# Configure and build glibc (with Ubuntu 20.04 deb configure call)
RUN cd /opt/thp-glibc/glibc-2.31/build && \
   ../configure --host=x86_64-linux-gnu --build= --prefix=/usr --enable-add-ons=libidn, --without-selinux --enable-stackguard-randomization --enable-stack-protector=strong --enable-obsolete-rpc --enable-obsolete-nsl --with-pkgversion="THP Ubuntu GLIBC 2.31-0ubuntu9" --with-bugurl=https://bugs.launchpad.net/ubuntu/+source/glibc/+bugs --disable-crypt --enable-kernel=3.2 --with-selinux --enable-systemtap --enable-multi-arch --enable-static-pie --enable-cet && \
   make

# Check whether out patches are in new libc.a, and copy into systems directory
RUN grep "GLIBC_THP_ALWAYS" /opt/thp-glibc/glibc-2.31/build/libc.a && \
    cp /opt/thp-glibc/glibc-2.31/build/libc.a /lib/x86_64-linux-gnu/libc.a


# Add anything build specific for the next tool you want to build (as docker likely caches the above)
RUN apt-get install -y cmake libgmp-dev
