FROM ubuntu:16.04

WORKDIR /build

ARG BUILD_PACKAGES='\
    libxcb1-dev \
    libxcb-keysyms1-dev \
    libpango1.0-dev \
    libxcb-util0-dev \
    libxcb-icccm4-dev \
    libyajl-dev \
    libstartup-notification0-dev \
    libxcb-randr0-dev \
    libev-dev \
    libxcb-cursor-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    autoconf \
    libxcb-xrm-dev \
    git \
    ca-certificates \
    checkinstall \
    libxcb-xkb-dev \
    libxcb-xinerama0-dev \
    libxcb-randr0-dev \
    libxcb-shape0-dev'

RUN echo 'deb http://ppa.launchpad.net/aguignard/ppa/ubuntu xenial main' > /etc/apt/sources.list.d/aguignard-ppa.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9058FBF6

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y $BUILD_PACKAGES

# https://github.com/Airblader/i3/wiki/Compiling-&-Installing#basics
# clone the repository
ARG VERSION
RUN git clone https://github.com/Airblader/i3.git . && \
    git checkout ${VERSION}

# compile & install
RUN autoreconf --force --install

# Disabling sanitizers is important for release versions!
# The prefix and sysconfdir are, obviously, dependent on the distribution.
RUN mkdir -p build && \
    mkdir -p /dist && \
    cd build/ && \
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers && \
    make && \
    echo 'i3-gaps – i3 with more features' >description-pak && \
    checkinstall \
      --type=debian \
      --maintainer=i3-gaps-deb \
      --nodoc \
      --pkgname=i3 \
      --pkgversion=${VERSION} \
      --default \
      --pakdir=/dist \
      --instal=no \
      --requires='libc6 \(\>= 2.14\),libcairo2 \(\>= 1.14.4\),libev4 \(\>= 1:4.04\),libglib2.0-0 \(\>= 2.12.0\),libpango-1.0-0 \(\>= 1.14.0\),libpangocairo-1.0-0 \(\>= 1.22.0\),libpcre3,libstartup-notification0 \(\>= 0.10\),libxcb-cursor0 \(\>= 0.0.99\),libxcb-icccm4 \(\>= 0.4.1\),libxcb-keysyms1 \(\>= 0.4.0\),libxcb-randr0 \(\>= 1.3\),libxcb-util1 \(\>= 0.4.0\),libxcb-xinerama0,libxcb-xkb1,libxcb-xrm0 \(\>= 0.0.0\),libxcb1 \(\>= 1.6\),libxkbcommon-x11-0 \(\>= 0.5.0\),libxkbcommon0 \(\>= 0.5.0\),libyajl2 \(\>= 2.0.4\),perl,x11-utils' \
      --provides='x-window-manager' \
      --replaces='i3,i3-wm'
