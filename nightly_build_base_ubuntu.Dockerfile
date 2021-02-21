FROM quay.io/icecodenew/builder_image_x86_64-linux:ubuntu AS rust-base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
# https://api.github.com/repos/rust-lang/rust/releases/latest
ENV rust_nightly_date='2020-11-26' \
    RUST_VERSION=1.48.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    PKG_CONFIG_ALL_STATIC=true \
    X86_64_UNKNOWN_LINUX_GNU_OPENSSL_DIR=/build_root/.openssl/ \
    X86_64_UNKNOWN_LINUX_GNU_OPENSSL_STATIC=1 \
    X86_64_UNKNOWN_LINUX_GNU_PCRE2_SYS_STATIC=1 \
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc \
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUNNER=wine \
    CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc-posix \
    CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++-posix \
    CARGO_TARGET_ARMV7_UNKNOWN_LINUX_MUSLEABI_LINKER=armv6-linux-musleabi-gcc \
    CARGO_TARGET_ARMV7_UNKNOWN_LINUX_MUSLEABI_RUNNER=qemu-arm \
    CC_armv7_unknown_linux_musleabi=armv6-linux-musleabi-gcc \
    CXX_armv7_unknown_linux_musleabi=armv6-linux-musleabi-g++
#     RUST_TEST_THREADS=1
# ENV CROSS_DOCKER_IN_DOCKER=true
# ENV CROSS_CONTAINER_ENGINE=podman
RUN apt-get update && apt-get -y --no-install-recommends install \
    apt-utils autoconf automake binutils build-essential ca-certificates checkinstall checksec cmake coreutils curl dos2unix file gettext git gpg gpg-agent libarchive-tools libedit-dev libltdl-dev liblzma-dev libncurses-dev libtool-bin libz-mingw-w64-dev locales mingw-w64 mingw-w64-tools netbase ninja-build pkgconf util-linux \
    && apt-get -y full-upgrade \
    # && dpkg --add-architecture i386 \
    # && curl -L https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    # && echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' > /etc/apt/sources.list.d/wine.develop.list \
    # && apt-get update && apt-get -y --install-recommends install \
    # winehq-devel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # && update-ca-certificates \
    # && for i in {1..2}; do checksec --update; done \
    && update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix \
    && update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix \
    && source '/root/.bashrc' \
    ### https://doc.rust-lang.org/nightly/rustc/platform-support.html
    && curl -OJ --compressed "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
    && chmod +x ./rustup-init \
    # && ./rustup-init -y -c rust-src -t x86_64-unknown-linux-gnu x86_64-unknown-linux-musl x86_64-pc-windows-gnu armv7-unknown-linux-musleabi --default-host x86_64-unknown-linux-gnu --profile minimal --default-toolchain nightly --no-modify-path \
    && ./rustup-init -y -t x86_64-unknown-linux-gnu x86_64-pc-windows-gnu armv7-unknown-linux-musleabi --default-host x86_64-unknown-linux-gnu --profile minimal --default-toolchain nightly --no-modify-path \
    && rm ./rustup-init \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    && cargo install cargo-deb \
    # && cargo install xargo \
    # && cargo install cross \
    && rm -rf "CARGO_HOME/git" "CARGO_HOME/registry" || exit 0 \
    # ### https://github.com/rust-embedded/cross/blob/master/docker/Dockerfile.x86_64-unknown-linux-musl
    # && curl -sS "https://musl.cc/x86_64-linux-musl-cross.tgz" | bsdtar -xf- -C /usr/local --strip-components 1 \
    ### https://github.com/rust-embedded/cross/blob/master/docker/Dockerfile.arm-unknown-linux-musleabi
    && curl -sS "https://musl.cc/armv6-linux-musleabi-cross.tgz" | bsdtar -xf- -C /usr/local --strip-components 1
