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
ENV rust_nightly_date='2020-11-26' \
    RUST_VERSION=1.48.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:/usr/lib/llvm-11/bin:$PATH \
    PKG_CONFIG_ALL_STATIC=true \
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=x86_64-linux-musl-gcc \
    CC_x86_64_unknown_linux_musl=x86_64-linux-musl-gcc \
    CXX_x86_64_unknown_linux_musl=x86_64-linux-musl-g++
ENV CROSS_DOCKER_IN_DOCKER=true
ENV CROSS_CONTAINER_ENGINE=podman
RUN apt-get update && apt-get -y --no-install-recommends install \
    apt-utils autoconf automake binutils build-essential ca-certificates checkinstall checksec cmake coreutils curl dos2unix git gpg gpg-agent libarchive-tools libedit-dev libtool-bin libz-mingw-w64-dev locales mingw-w64 mingw-w64-tools musl-tools ncurses-bin ninja-build pkgconf util-linux \
    && apt-get -y full-upgrade \
    && apt-get -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false purge \
    && curl -L 'https://apt.llvm.org/llvm-snapshot.gpg.key' | apt-key add - \
    && echo 'deb http://apt.llvm.org/focal/ llvm-toolchain-focal-11 main' > /etc/apt/sources.list.d/llvm.stable.list \
    && apt-get update && apt-get -y --install-recommends install \
    lld-11 \
    # && dpkg --add-architecture i386 \
    # && curl -L https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    # && echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' > /etc/apt/sources.list.d/wine.develop.list \
    # && apt-get update && apt-get -y --install-recommends install \
    # winehq-devel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    # && update-ca-certificates \
    # && for i in {1..2}; do checksec --update; done \
    && update-alternatives --install /usr/local/bin/ld ld /usr/lib/llvm-11/bin/lld 100 \
    && update-alternatives --auto ld \
    && update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix \
    && update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix \
    && curl -sSLR4q --retry 5 --retry-delay 10 --retry-max-time 60 --connect-timeout 60 -m 600 -o '/root/.bashrc' "https://raw.githubusercontent.com/IceCodeNew/myrc/${bashrc_latest_commit_hash}/.bashrc" \
    # && unset -f curl \
    # && eval "$(sed -E '/^curl\(\)/!d' /root/.bashrc)" \
    && source '/root/.bashrc' \
    && ( cd /usr || exit 1; curl -OJ --compressed "https://github.com/Kitware/CMake/releases/download/${cmake_latest_tag_name}/cmake-${cmake_latest_tag_name#v}-Linux-x86_64.sh" && bash "cmake-${cmake_latest_tag_name#v}-Linux-x86_64.sh" --skip-license && rm -f -- "/usr/cmake-${cmake_latest_tag_name#v}-Linux-x86_64.sh" '/usr/bin/cmake-gui' '/usr/bin/ccmake' '/usr/bin/ctest'; rm -rf -- /usr/share/cmake-3.16; true ) \
    && ( tmp_dir=$(mktemp -d) && pushd "$tmp_dir" || exit 1 && curl -sS "https://github.com/ninja-build/ninja/releases/download/${ninja_latest_tag_name}/ninja-linux.zip" | bsdtar -xf- && $(type -P install) -pvD './ninja' '/usr/bin/' && popd || exit 1 && /bin/rm -rf "$tmp_dir" && dirs -c ) \
    && mkdir '/usr/local/doc' \
    ### https://github.com/sabotage-linux/netbsd-curses
    && curl -sS --compressed "http://ftp.barfooze.de/pub/sabotage/tarballs/netbsd-curses-${netbsd_curses_tag_name}.tar.xz" | bsdtar -xf- \
    && ( cd "/netbsd-curses-${netbsd_curses_tag_name}" || exit 1; make CFLAGS="$CFLAGS -fPIC" PREFIX=/usr -j "$(nproc)" all install ) \
    && rm -rf "/netbsd-curses-${netbsd_curses_tag_name}" \
    ### https://github.com/sabotage-linux/gettext-tiny
    && curl -sS --compressed "http://ftp.barfooze.de/pub/sabotage/tarballs/gettext-tiny-${gettext_tiny_tag_name}.tar.xz" | bsdtar -xf- \
    && ( cd "/gettext-tiny-${gettext_tiny_tag_name}" || exit 1; make CFLAGS="$CFLAGS -fPIC" PREFIX=/usr -j "$(nproc)" all install ) \
    && rm -rf "/gettext-tiny-${gettext_tiny_tag_name}" \
    ### https://doc.rust-lang.org/nightly/rustc/platform-support.html
    && curl -OJ --compressed "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
    && chmod +x rustup-init \
    && ./rustup-init -y -c rust-src -t x86_64-unknown-linux-gnu x86_64-unknown-linux-musl x86_64-pc-windows-gnu --default-host x86_64-unknown-linux-gnu --profile minimal --no-modify-path \
    && rm rustup-init \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    && cargo install xargo \
    && cargo install cross; \
    rm -rf "/usr/local/cargo/registry" || exit 0 \
    ### https://github.com/rust-embedded/cross/blob/master/docker/Dockerfile.x86_64-unknown-linux-musl
    && ( tmp_dir=$(mktemp -d) && pushd "$tmp_dir" || exit 1 && curl -sS "https://github.com/richfelker/musl-cross-make/archive/master.tar.gz" | bsdtar -xf-  --strip-components=1 && make install "-j$(nproc)" DL_CMD='curl -sSLRq --retry 5 --retry-delay 10 --retry-max-time 60 --connect-timeout 60 -C - -o' LINUX_HEADERS_SITE="https://ci-mirrors.rust-lang.org/rustc/sabotage-linux-tarballs" OUTPUT=/usr/local/ TARGET=x86_64-linux-musl 'COMMON_CONFIG += CFLAGS="-Os -pipe -D_FORTIFY_SOURCE=2 -fexceptions -fstack-clash-protection -fstack-protector-strong -g0 -Wl,-z,noexecstack,-z,relro,-z,now,-z,defs -Wl,--icf=all" CXXFLAGS="-Os -pipe -D_FORTIFY_SOURCE=2 -fexceptions -fstack-clash-protection -fstack-protector-strong -g0 -Wl,-z,noexecstack,-z,relro,-z,now,-z,defs -Wl,--icf=all" LDFLAGS="-s -fuse-ld=lld"' && popd || exit 1 && /bin/rm -rf "$tmp_dir" && dirs -c )
