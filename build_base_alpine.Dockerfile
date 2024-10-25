FROM quay.io/icecodenew/alpine:latest AS rust-base
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# https://api.github.com/repos/slimm609/checksec.sh/releases/latest
ARG checksec_sh_latest_tag_name='2.4.0'
# https://api.github.com/repos/IceCodeNew/myrc/commits?per_page=1&path=.bashrc
ARG bashrc_latest_commit_hash='dffed49d1d1472f1b22b3736a5c191d74213efaa'
# https://api.github.com/repos/rust-lang/rust/releases/latest
ENV rust_nightly_date=2024-10-25 \
    RUST_VERSION=1.82.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    PKG_CONFIG_ALL_STATIC=true
# ENV CROSS_DOCKER_IN_DOCKER=true
# ENV CROSS_CONTAINER_ENGINE=podman
RUN apk update; apk --no-progress --no-cache add \
    apk-tools bash binutils build-base ca-certificates clang cmake coreutils curl dos2unix dpkg file gettext-tiny-dev grep libarchive-tools libedit-dev libedit-static lld mold musl musl-dev musl-libintl musl-utils ncurses ncurses-dev ncurses-static openssl pkgconf samurai; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    update-alternatives --install /usr/local/bin/ld ld /usr/bin/lld 1; \
    update-alternatives --install /usr/local/bin/ld ld /usr/bin/mold 100; \
    update-alternatives --auto ld; \
    curl -sSLR4q --retry 5 --retry-delay 10 --retry-max-time 60 --connect-timeout 60 -m 600 -o '/root/.bashrc' "https://raw.githubusercontent.com/IceCodeNew/myrc/${bashrc_latest_commit_hash}/.bashrc"; \
    unset -f curl; \
    eval 'curl() { /usr/bin/curl -LRq --retry 5 --retry-delay 10 --retry-max-time 60 "$@"; }'; \
    curl -sS4q -o '/usr/bin/checksec' "https://raw.githubusercontent.com/slimm609/checksec.sh/${checksec_sh_latest_tag_name}/checksec"; \
    chmod +x '/usr/bin/checksec'; \
    ### https://doc.rust-lang.org/nightly/rustc/platform-support.html
    curl -sSOJ --compressed "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-musl/rustup-init"; \
    chmod +x ./rustup-init; \
    ./rustup-init -y -c llvm-tools-preview -t x86_64-unknown-linux-musl --default-host x86_64-unknown-linux-musl --default-toolchain stable --profile minimal --no-modify-path; \
    rm ./rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME
# RUN rustup toolchain install nightly-x86_64-unknown-linux-musl --allow-downgrade --profile minimal --component llvm-tools-preview; \
#     rustup +nightly target add x86_64-unknown-linux-musl
