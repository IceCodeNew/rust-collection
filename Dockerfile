FROM alpine:edge AS rust-base
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# https://api.github.com/repos/slimm609/checksec.sh/commits?per_page=1
ARG checksec_latest_commit_hash='f3e56af80f7b24ebfdde5679b4a862d739636b11'
# https://api.github.com/repos/IceCodeNew/myrc/commits?per_page=1&path=.bashrc
ARG bashrc_latest_commit_hash='dffed49d1d1472f1b22b3736a5c191d74213efaa'
RUN apk update; apk --no-progress --no-cache add \
    apk-tools bash binutils build-base ca-certificates coreutils curl dos2unix dpkg file gettext-tiny-dev grep libarchive-tools libedit-dev libedit-static lld musl musl-dev musl-libintl musl-utils ncurses ncurses-dev ncurses-static openssl pkgconf rustup; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    update-alternatives --install /usr/local/bin/ld ld /usr/bin/lld 100; \
    update-alternatives --auto ld; \
    curl -sSL4q --retry 5 --retry-delay 10 --retry-max-time 60 -o '/usr/bin/checksec' "https://raw.githubusercontent.com/slimm609/checksec.sh/${checksec_latest_commit_hash}/checksec"; \
    chmod +x '/usr/bin/checksec'; \
    curl -sSL4q --retry 5 --retry-delay 10 --retry-max-time 60 -o '/root/.bashrc' "https://raw.githubusercontent.com/IceCodeNew/myrc/${bashrc_latest_commit_hash}/.bashrc"; \
    rustup-init -y -t x86_64-unknown-linux-musl

FROM rust-base AS b3sum
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BLAKE3-team/BLAKE3/releases/latest
ARG b3sum_latest_tag_name='0.3.7'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --target x86_64-unknown-linux-musl b3sum \
    && strip '/root/.cargo/bin/b3sum'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM scratch AS rust-collection
# date +%s
ARG cachebust='1603527789'
COPY --from=b3sum /root/.cargo/bin/b3sum /root/go/bin/b3sum
