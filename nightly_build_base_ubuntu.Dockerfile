FROM quay.io/icecodenew/ubuntu:latest AS rust-base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
# https://api.github.com/repos/slimm609/checksec.sh/releases/latest
ARG checksec_sh_latest_tag_name=2.4.0
# https://api.github.com/repos/IceCodeNew/myrc/commits?per_page=1&path=.bashrc
ARG bashrc_latest_commit_hash=dffed49d1d1472f1b22b3736a5c191d74213efaa
# https://api.github.com/repos/Kitware/CMake/releases/latest
ARG cmake_latest_tag_name=v3.19.1
# https://api.github.com/repos/ninja-build/ninja/releases/latest
ARG ninja_latest_tag_name=v1.10.1
# https://api.github.com/repos/sabotage-linux/netbsd-curses/releases/latest
ARG netbsd_curses_tag_name=0.3.1
# https://api.github.com/repos/sabotage-linux/gettext-tiny/releases/latest
ARG gettext_tiny_tag_name=0.3.2
# https://api.github.com/repos/rust-lang/rust/releases/latest
ARG rust_nightly_date='2020-11-26'
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    PKG_CONFIG_ALL_STATIC=true
ENV RUST_VERSION=1.48.0
ENV CROSS_DOCKER_IN_DOCKER=true
ENV CROSS_CONTAINER_ENGINE=podman
RUN apt-get update && apt-get -y --no-install-recommends install \
    apt-utils autoconf automake binutils build-essential ca-certificates checkinstall checksec cmake coreutils curl dos2unix git libarchive-tools libedit-dev libtool-bin libz-mingw-w64-dev lld locales mingw-w64 mingw-w64-tools musl-tools ncurses-bin ninja-build pkgconf util-linux \
    # apt-utils autoconf automake binutils build-essential ca-certificates checkinstall checksec cmake coreutils curl dos2unix git gpg gpg-agent libarchive-tools libedit-dev libtool-bin libz-mingw-w64-dev lld locales mingw-w64 mingw-w64-tools musl-tools ncurses-bin ninja-build pkgconf software-properties-common util-linux \
    && apt-get -y full-upgrade \
    && apt-get -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false purge \
    # && dpkg --add-architecture i386 \
    # && curl -L https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    # && add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' \
    # && apt-get update && apt-get -y --install-recommends install \
    # winehq-devel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    # && update-ca-certificates \
    # && for i in {1..2}; do checksec --update; done \
    && update-alternatives --install /usr/local/bin/ld ld /usr/bin/lld 100 \
    && update-alternatives --auto ld \
    && update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix \
    && update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix \
    && curl -LR4q --retry 5 --retry-delay 10 --retry-max-time 60 --connect-timeout 60 -m 600 -o '/root/.bashrc' "https://raw.githubusercontent.com/IceCodeNew/myrc/${bashrc_latest_commit_hash}/.bashrc" \
    && eval "$(sed -E '/^curl\(\)/!d' /root/.bashrc)" \
    && ( cd /usr || exit 1; curl -OJ "https://github.com/Kitware/CMake/releases/download/${cmake_latest_tag_name}/cmake-${cmake_latest_tag_name#v}-Linux-x86_64.sh" && bash "cmake-${cmake_latest_tag_name#v}-Linux-x86_64.sh" --skip-license && rm -f -- "/usr/cmake-${cmake_latest_tag_name#v}-Linux-x86_64.sh" '/usr/bin/cmake-gui' '/usr/bin/ctest' '/usr/bin/cpack' '/usr/bin/ccmake'; true ) \
    && ( curl -OJ "https://github.com/ninja-build/ninja/releases/download/${ninja_latest_tag_name}/ninja-linux.zip" && bsdtar -xf ninja-linux.zip && install -pvD "./ninja" "/usr/bin/" && rm -f -- './ninja' 'ninja-linux.zip' ) \
    && mkdir -p '/usr/local/doc' \
    ### https://github.com/sabotage-linux/netbsd-curses
    && curl -OJ "http://ftp.barfooze.de/pub/sabotage/tarballs/netbsd-curses-${netbsd_curses_tag_name}.tar.xz" \
    && bsdtar -xf "netbsd-curses-${netbsd_curses_tag_name}.tar.xz" \
    && ( cd "/netbsd-curses-${netbsd_curses_tag_name}" || exit 1; make CFLAGS="$CFLAGS -fPIC" PREFIX=/usr -j "$(nproc)" all install ) \
    && rm -rf "/netbsd-curses-${netbsd_curses_tag_name}"* \
    ### https://github.com/sabotage-linux/gettext-tiny
    && curl -OJ "http://ftp.barfooze.de/pub/sabotage/tarballs/gettext-tiny-${gettext_tiny_tag_name}.tar.xz" \
    && bsdtar -xf "gettext-tiny-${gettext_tiny_tag_name}.tar.xz" \
    && ( cd "/gettext-tiny-${gettext_tiny_tag_name}" || exit 1; make CFLAGS="$CFLAGS -fPIC" PREFIX=/usr -j "$(nproc)" all install ) \
    && rm -rf "/gettext-tiny-${gettext_tiny_tag_name}"* \
    && curl -OJ "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
    && chmod +x rustup-init \
    && ./rustup-init -y -c rust-src -t x86_64-unknown-linux-gnu x86_64-pc-windows-gnu --default-host x86_64-unknown-linux-gnu --profile minimal --default-toolchain nightly --no-modify-path \
    && rm rustup-init \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    && cargo install xargo \
    && cargo install cross; \
    rm -rf "/usr/local/cargo/registry" || exit 0
