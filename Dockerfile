FROM quay.io/icecodenew/rust-collection:nightly_build_base_ubuntu AS shadowsocks-rust
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/shadowsocks/shadowsocks-rust/commits?per_page=1
ARG shadowsocks_rust_latest_commit_hash='5d42ac9371e665b905161b5683ddfd3c8a208dd8'
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C target-feature=+crt-static" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --no-default-features --features "trust-dns local-http local-http-rustls local-tunnel local-socks4 local-redir mimalloc" --git 'https://github.com/shadowsocks/shadowsocks-rust.git' --verbose \
    && cd /usr/local/cargo/bin || exit 1 \
    && strip sslocal ssmanager ssserver ssurl \
    && bsdtar -a -cf ss-rust-linux-gnu-x64.tar.xz sslocal ssmanager ssserver ssurl; \
    rm -f sslocal ssmanager ssserver ssurl
RUN LDFLAGS="$(echo "$LDFLAGS" | sed -E 's/ -fuse-ld=lld//')" \
    && CXXFLAGS="$(echo "$CXXFLAGS" | sed -E -e 's/ -Wl,--icf=all//' -e 's/ -D_FORTIFY_SOURCE=2//' -e 's/ -fstack-clash-protection -fstack-protector-strong//')" \
    && CFLAGS="$(echo "$CFLAGS" | sed -E -e 's/ -Wl,--icf=all//' -e 's/ -D_FORTIFY_SOURCE=2//' -e 's/ -fstack-clash-protection -fstack-protector-strong//')" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && RUSTFLAGS="-C target-feature=+crt-static" cargo install --bins -j "$(nproc)" --target x86_64-pc-windows-gnu --no-default-features --features "trust-dns local-http local-http-rustls local-tunnel local-socks4" --git 'https://github.com/shadowsocks/shadowsocks-rust.git' --verbose \
    && cd /usr/local/cargo/bin || exit 1 \
    && bsdtar -a -cf ss-rust-win-gnu-x64.zip sslocal.exe ssmanager.exe ssserver.exe ssurl.exe; \
    rm -rf sslocal.exe ssmanager.exe ssserver.exe ssurl.exe "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS b3sum
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BLAKE3-team/BLAKE3/releases/latest
ARG b3sum_latest_tag_name='0.3.7'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl b3sum --verbose \
    && strip '/usr/local/cargo/bin/b3sum'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS fd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/fd/releases/latest
ARG fd_latest_tag_name='v8.1.1'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl fd-find --verbose \
    && strip '/usr/local/cargo/bin/fd'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS bat
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/bat/releases/latest
ARG bat_latest_tag_name='v0.16.0'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --locked bat --verbose \
    && strip '/usr/local/cargo/bin/bat'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS hexyl
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hexyl/releases/latest
ARG hexyl_latest_tag_name='v0.8.0'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hexyl --verbose \
    && strip '/usr/local/cargo/bin/hexyl'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS hyperfine
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hyperfine/releases/latest
ARG hyperfine_latest_tag_name='v1.11.0'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hyperfine --verbose \
    && strip '/usr/local/cargo/bin/hyperfine'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS desed
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/SoptikHa2/desed/releases/latest
ARG desed_latest_tag_name='v1.2.0'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl desed --verbose \
    && strip '/usr/local/cargo/bin/desed'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS fnm
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/Schniz/fnm/releases/latest
ARG fnm_latest_tag_name='v1.22.6'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/Schniz/fnm.git' --tag "$fnm_latest_tag_name" --verbose \
    && strip '/usr/local/cargo/bin/fnm'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS checksec
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/etke/checksec.rs/releases/latest
ARG checksec_rs_latest_tag_name='v0.0.8'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl checksec --verbose \
    && strip '/usr/local/cargo/bin/checksec'; \
    rm -rf "/usr/local/cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS boringtun
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/cloudflare/boringtun/commits?per_page=1
ARG boringtun_latest_commit_hash='a6d9d059a72466c212fa3055170c67ca16cb935b'
RUN source '/root/.bashrc' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/cloudflare/boringtun.git' --verbose \
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
COPY --from=desed /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=fnm /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=checksec /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=boringtun /usr/local/cargo/bin /usr/local/cargo/bin/
RUN apk update; apk --no-progress --no-cache add \
    bash coreutils curl tzdata; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    cp -f /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime
