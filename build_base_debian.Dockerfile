FROM quay.io/icecodenew/builder_image_x86_64-linux:debian AS rust-base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
# https://api.github.com/repos/rust-lang/rust/releases/latest
ENV rust_nightly_date=2024-10-25 \
    RUST_VERSION=1.82.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
#     RUST_TEST_THREADS=1
# ENV CROSS_DOCKER_IN_DOCKER=true
# ENV CROSS_CONTAINER_ENGINE=podman
# RUN dpkg --add-architecture i386 \
#     && curl -fsSLR 'https://dl.winehq.org/wine-builds/winehq.key' -o '/usr/share/keyrings/winehq-archive.key' \
#     && curl -fsSLR 'https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources' -o '/etc/apt/sources.list.d/winehq-bullseye.sources' \
#     && apt-get update && apt-get -y --install-recommends install \
#     winehq-devel \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
RUN install_packages \
    gettext liblzma-dev libz-mingw-w64-dev mingw-w64 mingw-w64-tools \
    # && update-ca-certificates \
    && update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix \
    && update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix \
    && source '/root/.bashrc' \
    ### https://doc.rust-lang.org/nightly/rustc/platform-support.html
    && curl -sSOJ --compressed "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
    && chmod +x ./rustup-init \
    && ./rustup-init -y -c llvm-tools-preview -t x86_64-unknown-linux-gnu x86_64-pc-windows-gnu --default-host x86_64-unknown-linux-gnu --default-toolchain stable --profile minimal --no-modify-path \
    && rm ./rustup-init \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    && mold -run cargo install -j "$(nproc)" cargo-deb \
    # && mold -run cargo install -j "$(nproc)" cargo-audit --features=fix \
    # && mold -run cargo install -j "$(nproc)" xargo \
    # && mold -run cargo install -j "$(nproc)" cross \
    && rm -rf "CARGO_HOME/git" "CARGO_HOME/registry" || exit 0
    # ### https://github.com/rust-embedded/cross/blob/master/docker/Dockerfile.x86_64-unknown-linux-musl
    # && curl -sS "https://musl.cc/x86_64-linux-musl-cross.tgz" | bsdtar -xf- -C /usr/local --strip-components 1 \
# RUN rustup toolchain install nightly-x86_64-unknown-linux-gnu --allow-downgrade --profile minimal --component llvm-tools-preview \
#     # && rustup component add --toolchain nightly --target x86_64-unknown-linux-gnu reproducible-artifacts \
#     && rustup +nightly target add x86_64-unknown-linux-gnu x86_64-pc-windows-gnu

ENV PKG_CONFIG_ALL_STATIC=true \
    X86_64_UNKNOWN_LINUX_GNU_OPENSSL_LIB_DIR=/usr/lib \
    X86_64_UNKNOWN_LINUX_GNU_OPENSSL_INCLUDE_DIR=/usr/include \
    X86_64_UNKNOWN_LINUX_GNU_OPENSSL_STATIC=1 \
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc \
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUNNER=wine \
    CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc-posix \
    CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++-posix
