FROM quay.io/icecodenew/alpine:edge AS rust-base
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# https://api.github.com/repos/slimm609/checksec.sh/releases/latest
ARG checksec_sh_latest_tag_name=2.4.0
# https://api.github.com/repos/IceCodeNew/myrc/commits?per_page=1&path=.bashrc
ARG bashrc_latest_commit_hash=dffed49d1d1472f1b22b3736a5c191d74213efaa
ARG rust_nightly_date='2020-11-26'
ENV CROSS_DOCKER_IN_DOCKER=true
ENV CROSS_CONTAINER_ENGINE=podman
ENV PKG_CONFIG_ALL_STATIC=true
RUN apk update; apk --no-progress --no-cache add \
    apk-tools bash binutils build-base ca-certificates cmake coreutils curl dos2unix dpkg file gettext-tiny-dev grep libarchive-tools libedit-dev libedit-static lld musl musl-dev musl-libintl musl-utils ncurses ncurses-dev ncurses-static openssl pkgconf rustup samurai; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    update-alternatives --install /usr/local/bin/ld ld /usr/bin/lld 100; \
    update-alternatives --auto ld; \
    curl -sSL4q --retry 5 --retry-delay 10 --retry-max-time 60 -o '/usr/bin/checksec' "https://raw.githubusercontent.com/slimm609/checksec.sh/${checksec_sh_latest_tag_name}/checksec"; \
    chmod +x '/usr/bin/checksec'; \
    curl -sSL4q --retry 5 --retry-delay 10 --retry-max-time 60 -o '/root/.bashrc' "https://raw.githubusercontent.com/IceCodeNew/myrc/${bashrc_latest_commit_hash}/.bashrc"; \
    rustup-init -y -c rust-src -t x86_64-unknown-linux-musl x86_64-pc-windows-gnu --default-host x86_64-unknown-linux-musl --profile minimal --default-toolchain nightly; \
    source $HOME/.cargo/env; \
    cargo install xargo; \
    cargo install cross
