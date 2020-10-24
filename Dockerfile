FROM alpine:edge AS rust-base
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk update; apk --no-progress --no-cache add \
    apk-tools bash binutils ca-certificates cargo coreutils curl dos2unix file grep libarchive-tools musl musl-dev musl-utils openssl pkgconf rust rust-stdlib; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*

FROM rust-base AS b3sum
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# https://api.github.com/repos/BLAKE3-team/BLAKE3/releases/latest
ARG github_release_latest_tag_name='0.3.7'
RUN cargo install b3sum; \
    strip '/root/.cargo/bin/b3sum'; \
    rm -rf "/root/.cargo/registry" || exit 0
