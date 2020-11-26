FROM quay.io/icecodenew/rust-collection:nightly_build_base_ubuntu AS shadowsocks-rust
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/shadowsocks/shadowsocks-rust/commits?per_page=1
ARG shadowsocks_rust_latest_commit_hash='5d42ac9371e665b905161b5683ddfd3c8a208dd8'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --no-default-features --features "trust-dns local-http local-http-rustls local-tunnel local-socks4 local-redir mimalloc" --git 'https://github.com/shadowsocks/shadowsocks-rust.git' \
    && cd /usr/local/cargo/bin || exit 1 \
    && strip sslocal ssmanager ssserver ssurl \
    && bsdtar -cJf ss-rust-linux-gnu-x64.tar.xz sslocal ssmanager ssserver ssurl; \
    rm -rf sslocal ssmanager ssserver ssurl "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS b3sum
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BLAKE3-team/BLAKE3/releases/latest
ARG b3sum_latest_tag_name='0.3.7'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl b3sum \
    && strip '/usr/local/cargo/bin/b3sum'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS fd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/fd/releases/latest
ARG fd_latest_tag_name='v8.1.1'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl fd-find \
    && strip '/usr/local/cargo/bin/fd'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS bat
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/bat/releases/latest
ARG bat_latest_tag_name='v0.16.0'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --locked bat \
    && strip '/usr/local/cargo/bin/bat'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS hexyl
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hexyl/releases/latest
ARG hexyl_latest_tag_name='v0.8.0'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hexyl \
    && strip '/usr/local/cargo/bin/hexyl'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS hyperfine
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hyperfine/releases/latest
ARG hyperfine_latest_tag_name='v1.11.0'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hyperfine \
    && strip '/usr/local/cargo/bin/hyperfine'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS fnm
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/Schniz/fnm/releases/latest
ARG fnm_latest_tag_name='v1.22.6'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/Schniz/fnm.git' --tag "$fnm_latest_tag_name" \
    && strip '/usr/local/cargo/bin/fnm'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS checksec
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/etke/checksec.rs/releases/latest
ARG checksec_rs_latest_tag_name='v0.0.8'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl checksec \
    && strip '/usr/local/cargo/bin/checksec'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:nightly_build_base_alpine AS boringtun
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/cloudflare/boringtun/commits?per_page=1
ARG boringtun_latest_commit_hash='a6d9d059a72466c212fa3055170c67ca16cb935b'
RUN source '/root/.bashrc' \
    && source '/usr/local/cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/cloudflare/boringtun.git' \
    && strip '/usr/local/cargo/bin/boringtun'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/alpine:edge AS collection
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# date +%s
ARG cachebust='1603527789'
ARG TZ='Asia/Taipei'
ENV DEFAULT_TZ ${TZ}
COPY --from=shadowsocks-rust /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=b3sum /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=fd /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=bat /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=hexyl /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=hyperfine /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=fnm /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=checksec /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=boringtun /usr/local/cargo/bin /usr/local/cargo/bin/
RUN apk update; apk --no-progress --no-cache add \
    bash coreutils curl tzdata; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    cp -f /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime
