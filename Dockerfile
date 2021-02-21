FROM quay.io/icecodenew/rust-collection:build_base_ubuntu AS shadowsocks-rust
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/shadowsocks/shadowsocks-rust/commits?per_page=1
ARG shadowsocks_rust_latest_commit_hash='5d42ac9371e665b905161b5683ddfd3c8a208dd8'
WORKDIR /usr/local/cargo/bin
RUN LDFLAGS="-fuse-ld=lld -s" \
    && CXXFLAGS="-O3 -pipe -g0 -Wl,-z,noexecstack,-z,relro,-z,now,-z,defs -Wl,--icf=all" \
    && CFLAGS="-O3 -pipe -g0 -Wl,-z,noexecstack,-z,relro,-z,now,-z,defs -Wl,--icf=all" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && RUSTFLAGS="-C relocation-model=static -C prefer-dynamic=off -C target-feature=-crt-static,-avx2,-fma,-adx -C link-arg=-fuse-ld=lld" cargo +nightly install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --no-default-features --features "logging trust-dns server manager multi-threaded mimalloc" --git 'https://github.com/shadowsocks/shadowsocks-rust.git' --verbose \
    && strip ./ssmanager ./ssserver \
    && bsdtar --no-xattrs -a -cf 4limit-mem-server-only-ss-rust-linux-gnu-x64.tar.gz ./ssmanager ./ssserver \
    && rm -f ./ssmanager ./ssserver
RUN LDFLAGS="-s" \
    && CXXFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && CFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && RUSTFLAGS="-C prefer-dynamic=off -C target-feature=+crt-static,+avx2,+fma,+adx" cargo +nightly install --bins -j "$(nproc)" --target x86_64-pc-windows-gnu --no-default-features --features "logging trust-dns dns-over-tls dns-over-https local utility local-dns local-http local-tunnel local-socks4 multi-threaded" --git 'https://github.com/shadowsocks/shadowsocks-rust.git' --verbose \
    && x86_64-w64-mingw32-strip ./sslocal.exe ./ssurl.exe \
    && bsdtar --no-xattrs -a -cf ss-rust-win-gnu-x64.zip ./sslocal.exe ./ssurl.exe \
    && rm -f ./sslocal.exe ./ssurl.exe
RUN unset LDFLAGS CXXFLAGS CFLAGS \
    && source '/root/.bashrc' \
    && export LDFLAGS="-fuse-ld=lld -s" \
    && env \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=+crt-static,-vfp2,-vfp3" cargo +nightly install --bins -j "$(nproc)" --target armv7-unknown-linux-musleabi --no-default-features --features "logging trust-dns dns-over-tls dns-over-https local utility local-dns local-http local-tunnel local-socks4 multi-threaded local-redir" --git 'https://github.com/shadowsocks/shadowsocks-rust.git' --verbose \
    && armv6-linux-musleabi-strip ./sslocal ./ssurl \
    && bsdtar --no-xattrs -a -cf ss-rust-linux-arm-musleabi5-x32.tar.gz ./sslocal ./ssurl \
    && rm -f ./sslocal ./ssurl
RUN unset LDFLAGS CXXFLAGS CFLAGS \
    && source '/root/.bashrc' \
    && env \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static,+avx2,+fma,+adx -C link-arg=-fuse-ld=lld" cargo +nightly install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --no-default-features --features "logging trust-dns dns-over-tls dns-over-https local server manager utility local-dns local-http local-tunnel local-socks4 multi-threaded local-redir mimalloc" --git 'https://github.com/shadowsocks/shadowsocks-rust.git' --verbose \
    && strip ./sslocal ./ssmanager ./ssserver ./ssurl \
    && bsdtar --no-xattrs -a -cf ss-rust-linux-gnu-x64.tar.xz ./sslocal ./ssmanager ./ssserver ./ssurl \
    && rm -f ./sslocal ./ssmanager ./ssserver ./ssurl \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_ubuntu AS boringtun
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/cloudflare/boringtun/commits?per_page=1
ARG boringtun_latest_commit_hash='a6d9d059a72466c212fa3055170c67ca16cb935b'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --git 'https://github.com/cloudflare/boringtun.git' --verbose \
    && strip -o ./boringtun-linux-gnu-x64 ./boringtun \
    && rm -f ./boringtun \
RUN export LDFLAGS="-s -fuse-ld=lld" \
    && env \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=+crt-static -C target-feature=-vfp2 -C target-feature=-vfp3" cargo install --bins -j "$(nproc)" --target armv7-unknown-linux-musleabi --git 'https://github.com/cloudflare/boringtun.git' --verbose \
    && armv6-linux-musleabi-strip -o ./boringtun-linux-arm-musleabi5-x32 ./boringtun \
    && rm -f ./boringtun \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_ubuntu AS dog
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/ogham/dog/commits?per_page=1
ARG dog_latest_commit_hash='d2d22fd8a4ba79027b5e2013d4ded3743dad5262'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --git 'https://github.com/ogham/dog.git' dog --verbose \
    && strip ./dog \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_ubuntu AS websocat
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/vi/websocat/commits?per_page=1
ARG websocat_latest_commit_hash='4a421b7181aa5ab0101be68041f7c9cc9bdb2569'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --features=ssl --git 'https://github.com/vi/websocat.git' websocat --verbose \
    && strip ./websocat \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_ubuntu AS rsign2
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/jedisct1/rsign2/commits?per_page=1
ARG rsign2_latest_commit_hash='79e058b7c18bcd519f160b5391c240549a0f5fdc'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --git 'https://github.com/jedisct1/rsign2.git' --verbose \
    && strip ./rsign \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_ubuntu AS b3sum
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BLAKE3-team/BLAKE3/releases/latest
ARG b3sum_latest_tag_name='0.3.7'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu b3sum --verbose \
    && strip ./b3sum \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_ubuntu AS ripgrep
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BurntSushi/ripgrep/commits?per_page=1
ARG ripgrep_latest_commit_hash='c5ea5a13df8de5b7823e5ecad00bad1c4c4c854d'
WORKDIR /git/ripgrep
RUN source '/root/.bashrc' \
    && git_clone 'https://github.com/BurntSushi/ripgrep.git' '/git/ripgrep' \
    && cargo update --verbose || exit 1; \
    if ! RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static -C link-arg=-fuse-ld=lld" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --features 'pcre2' --release --verbose; \
    then git reset --hard "$ripgrep_latest_commit_hash" \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-feature=-crt-static -C link-arg=-fuse-ld=lld" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --features 'pcre2' --release --verbose; \
    fi; \
    strip -o /usr/local/cargo/bin/rg ./target/x86_64-unknown-linux-gnu/release/rg \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup '/git/ripgrep' "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS fd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/fd/releases/latest
ARG fd_latest_tag_name='v8.1.1'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl fd-find --verbose \
    && strip ./fd \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS bat
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/bat/releases/latest
ARG bat_latest_tag_name='v0.16.0'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --locked bat --verbose \
    && strip ./bat \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS hexyl
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hexyl/releases/latest
ARG hexyl_latest_tag_name='v0.8.0'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hexyl --verbose \
    && strip ./hexyl \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS hyperfine
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hyperfine/releases/latest
ARG hyperfine_latest_tag_name='v1.11.0'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hyperfine --verbose \
    && strip ./hyperfine \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS fnm
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/Schniz/fnm/releases/latest
ARG fnm_latest_tag_name='v1.22.6'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/Schniz/fnm.git' --tag "$fnm_latest_tag_name" --verbose \
    && strip ./fnm \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS checksec
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/etke/checksec.rs/releases/latest
ARG checksec_rs_latest_tag_name='v0.0.8'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl checksec --verbose \
    && strip ./checksec \
    && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_alpine AS just
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/casey/just/commits?per_page=1
# ARG just_latest_commit_hash='d43241a781aa3abd9b76dc7baf030593bb61b689'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/casey/just.git' just --verbose \
#     && strip ./just \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_alpine AS desed
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/SoptikHa2/desed/releases/latest
# ARG desed_latest_tag_name='v1.2.0'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C link-arg=-fuse-ld=lld" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl desed --verbose \
#     && strip ./desed \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-gdb ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "CARGO_HOME/git" "CARGO_HOME/registry"

FROM quay.io/icecodenew/alpine:latest AS collection
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# date +%s
# ARG cachebust='1603527789'
ARG TZ='Asia/Taipei'
ENV DEFAULT_TZ ${TZ}
COPY --from=shadowsocks-rust /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=boringtun /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=dog /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=websocat /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=rsign2 /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=b3sum /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=ripgrep /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=fd /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=bat /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=hexyl /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=hyperfine /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=fnm /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=checksec /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=just /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=desed /usr/local/cargo/bin /usr/local/cargo/bin/
RUN apk update; apk --no-progress --no-cache add \
    bash coreutils curl tzdata; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    cp -f /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime
