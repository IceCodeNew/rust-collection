FROM quay.io/icecodenew/rust-collection:build_base_debian AS shadowsocks-rust
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/shadowsocks/shadowsocks-rust/commits?per_page=1
ARG shadowsocks_rust_latest_commit_hash='5d42ac9371e665b905161b5683ddfd3c8a208dd8'
WORKDIR /git/shadowsocks-rust
RUN source '/root/.bashrc' \
    && LDFLAGS="-s" \
    && CXXFLAGS="-O3 -pipe -g0 -Wl,-z,noexecstack,-z,relro,-z,now,-z,defs -Wl,--icf=all" \
    && CFLAGS="-O3 -pipe -g0 -Wl,-z,noexecstack,-z,relro,-z,now,-z,defs -Wl,--icf=all" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && git clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch 'https://github.com/shadowsocks/shadowsocks-rust.git' '/git/shadowsocks-rust' \
    && RUSTFLAGS="-C relocation-model=static -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=+crt-static -C link-arg=-fuse-ld=mold" cargo build --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --no-default-features --features "logging hickory-dns utility server manager multi-threaded aead-cipher-2022 mimalloc" --release --verbose \
    && strip -o "./ssurl" ./target/x86_64-unknown-linux-gnu/release/ssurl \
    && strip -o "./ssmanager" ./target/x86_64-unknown-linux-gnu/release/ssmanager \
    && strip -o "./ssserver" ./target/x86_64-unknown-linux-gnu/release/ssserver \
    && bsdtar --no-xattrs -a -cf "/usr/local/cargo/bin/4limit-mem-server-only-ss-rust-linux-gnu-x64.tar.gz" "./ssurl" "./ssmanager" "./ssserver"
RUN LDFLAGS="-s" \
    && CXXFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && CFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && RUSTFLAGS="-C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=+crt-static" cargo build --bins -j "$(nproc)" --target x86_64-pc-windows-gnu --no-default-features --features "logging hickory-dns dns-over-tls dns-over-https dns-over-h3 local utility winservice local-dns local-http local-tunnel local-socks4 multi-threaded aead-cipher-2022" --release --verbose \
    && x86_64-w64-mingw32-strip -o "./sslocal.exe" ./target/x86_64-pc-windows-gnu/release/sslocal.exe \
    && x86_64-w64-mingw32-strip -o "./ssurl.exe" ./target/x86_64-pc-windows-gnu/release/ssurl.exe \
    && x86_64-w64-mingw32-strip -o "./sswinservice.exe" ./target/x86_64-pc-windows-gnu/release/sswinservice.exe \
    && bsdtar --no-xattrs -a -cf "/usr/local/cargo/bin/ss-rust-win-gnu-x64.zip" "./sslocal.exe" "./ssurl.exe" "./sswinservice.exe"
# RUN unset LDFLAGS CXXFLAGS CFLAGS \
#     && source '/root/.bashrc' \
#     && export LDFLAGS="-s" \
#     && env \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=+crt-static,-vfp2,-vfp3" cargo build --bins -j "$(nproc)" --target armv7-unknown-linux-musleabi --no-default-features --features "logging hickory-dns dns-over-tls dns-over-https dns-over-h3 local utility local-dns local-http local-tunnel local-socks4 multi-threaded aead-cipher-2022 local-redir local-tun" --release --verbose \
#     && armv6-linux-musleabi-strip -o "./sslocal" ./target/armv7-unknown-linux-musleabi/release/sslocal \
#     && armv6-linux-musleabi-strip -o "./ssurl" ./target/armv7-unknown-linux-musleabi/release/ssurl \
#     && bsdtar --no-xattrs -a -cf "/usr/local/cargo/bin/ss-rust-linux-arm-musleabi5-x32.tar.gz" "./sslocal" "./ssurl"
RUN unset LDFLAGS CXXFLAGS CFLAGS \
    && source '/root/.bashrc' \
    && env \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo build --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --no-default-features --features "logging hickory-dns dns-over-tls dns-over-https dns-over-h3 utility service local-dns local-http local-tunnel local-socks4 multi-threaded aead-cipher-2022 local-redir local-tun mimalloc" --release --verbose \
    && strip -o "./ssurl" ./target/x86_64-unknown-linux-gnu/release/ssurl \
    && strip -o "./ssservice" ./target/x86_64-unknown-linux-gnu/release/ssservice \
    && bsdtar --no-xattrs -a -cf "/usr/local/cargo/bin/ss-rust-linux-gnu-x64.tar.xz" "./ssurl" "./ssservice" \
    && rm -rf '/git/shadowsocks-rust' "/usr/local/cargo/bin/cargo" "/usr/local/cargo/bin/cargo-clippy" "/usr/local/cargo/bin/cargo-deb" "/usr/local/cargo/bin/cargo-audit" "/usr/local/cargo/bin/cargo-fmt" "/usr/local/cargo/bin/cargo-miri" "/usr/local/cargo/bin/clippy-driver" "/usr/local/cargo/bin/rls ./rust-analyzer" "/usr/local/cargo/bin/rust-gdb" "/usr/local/cargo/bin/rust-gdbgui" "/usr/local/cargo/bin/rust-lldb" "/usr/local/cargo/bin/rustc" "/usr/local/cargo/bin/rustdoc" "/usr/local/cargo/bin/rustfmt" "/usr/local/cargo/bin/rustup" "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_debian AS cfnts
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/cloudflare/cfnts/commits?per_page=1
# ARG cfnts_latest_commit_hash='3d9c673e1b7abbad1bd691ef7c1608582e8371a6'
# WORKDIR /git/cfnts
# RUN source '/root/.bashrc' \
#     && git clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch 'https://github.com/cloudflare/cfnts.git' '/git/cfnts' \
#     && cargo update --verbose || exit 1; \
#     if ! RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static,+aes,+ssse3 -C link-arg=-fuse-ld=mold" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --release --verbose; \
#     then git reset --hard "$cfnts_latest_commit_hash" \
#     && echo "$ git reset --hard $shadowsocks_rust_latest_commit_hash" \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static,+aes,+ssse3 -C link-arg=-fuse-ld=mold" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --release --verbose; \
#     fi; \
#     strip -o "/usr/local/cargo/bin/cfnts" ./target/x86_64-unknown-linux-gnu/release/cfnts \
#     && rm -rf '/git/cfnts' "/usr/local/cargo/bin/cargo" "/usr/local/cargo/bin/cargo-clippy" "/usr/local/cargo/bin/cargo-deb" "/usr/local/cargo/bin/cargo-audit" "/usr/local/cargo/bin/cargo-fmt" "/usr/local/cargo/bin/cargo-miri" "/usr/local/cargo/bin/clippy-driver" "/usr/local/cargo/bin/rls ./rust-analyzer" "/usr/local/cargo/bin/rust-gdb" "/usr/local/cargo/bin/rust-gdbgui" "/usr/local/cargo/bin/rust-lldb" "/usr/local/cargo/bin/rustc" "/usr/local/cargo/bin/rustdoc" "/usr/local/cargo/bin/rustfmt" "/usr/local/cargo/bin/rustup" "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_debian AS dog
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/ogham/dog/commits?per_page=1
# ARG dog_latest_commit_hash='d2d22fd8a4ba79027b5e2013d4ded3743dad5262'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --git 'https://github.com/ogham/dog.git' dog --verbose \
#     && strip ./dog \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

FROM quay.io/icecodenew/rust-collection:build_base_debian AS qft
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/TudbuT/qft/commits?per_page=1
ARG qft_latest_commit_hash='198fdc54755a61edcc4712c63fb7b0b2423273e8'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=static -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=+crt-static -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --no-default-features --git 'https://github.com/TudbuT/qft.git' --verbose \
    && strip ./qft \
    && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_debian AS websocat
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/vi/websocat/commits?per_page=1
# ARG websocat_latest_commit_hash='4a421b7181aa5ab0101be68041f7c9cc9bdb2569'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --features=ssl --git 'https://github.com/vi/websocat.git' websocat --verbose \
#     && strip ./websocat \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

FROM quay.io/icecodenew/rust-collection:build_base_debian AS rsign2
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/jedisct1/rsign2/commits?per_page=1
ARG rsign2_latest_commit_hash='79e058b7c18bcd519f160b5391c240549a0f5fdc'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --git 'https://github.com/jedisct1/rsign2.git' --verbose \
    && mv ./rsign ./rsign-stripped
RUN LDFLAGS="-s" \
    && CXXFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && CFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && RUSTFLAGS="-C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=+crt-static" cargo install --bins -j "$(nproc)" --target x86_64-pc-windows-gnu --git 'https://github.com/jedisct1/rsign2.git' --verbose \
    && x86_64-w64-mingw32-strip ./rsign.exe \
    && strip -p -o ./rsign ./rsign-stripped \
    && rm -rf ./rsign-stripped ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

FROM quay.io/icecodenew/rust-collection:build_base_debian AS b3sum
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BLAKE3-team/BLAKE3/releases/latest
ARG b3sum_latest_tag_name='0.3.7'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu b3sum --verbose \
    && mv ./b3sum ./b3sum-stripped
RUN LDFLAGS="-s" \
    && CXXFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && CFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && RUSTFLAGS="-C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=+crt-static" cargo install --bins -j "$(nproc)" --target x86_64-pc-windows-gnu b3sum --verbose \
    && x86_64-w64-mingw32-strip ./b3sum.exe \
    && strip -p -o ./b3sum ./b3sum-stripped \
    && rm -rf ./b3sum-stripped ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

FROM quay.io/icecodenew/rust-collection:build_base_debian AS ripgrep
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BurntSushi/ripgrep/commits?per_page=1
ARG ripgrep_latest_commit_hash='c5ea5a13df8de5b7823e5ecad00bad1c4c4c854d'
WORKDIR /git/ripgrep
RUN source '/root/.bashrc' \
    && git clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch 'https://github.com/BurntSushi/ripgrep.git' '/git/ripgrep' \
    && cargo update --verbose || exit 1; \
    if ! RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --features 'pcre2' --release --verbose; \
    then git reset --hard "$ripgrep_latest_commit_hash" \
    && echo "$ git reset --hard $ripgrep_latest_commit_hash" \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --features 'pcre2' --release --verbose; \
    fi; \
    strip -o "/usr/local/cargo/bin/rg" ./target/x86_64-unknown-linux-gnu/release/rg \
    && "/usr/local/cargo/bin/rg" --pcre2-version \
    && rm -rf '/git/ripgrep' "/usr/local/cargo/bin/cargo" "/usr/local/cargo/bin/cargo-clippy" "/usr/local/cargo/bin/cargo-deb" "/usr/local/cargo/bin/cargo-audit" "/usr/local/cargo/bin/cargo-fmt" "/usr/local/cargo/bin/cargo-miri" "/usr/local/cargo/bin/clippy-driver" "/usr/local/cargo/bin/rls ./rust-analyzer" "/usr/local/cargo/bin/rust-gdb" "/usr/local/cargo/bin/rust-gdbgui" "/usr/local/cargo/bin/rust-lldb" "/usr/local/cargo/bin/rustc" "/usr/local/cargo/bin/rustdoc" "/usr/local/cargo/bin/rustfmt" "/usr/local/cargo/bin/rustup" "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_debian AS coreutils
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/uutils/coreutils/commits?per_page=1
# ARG coreutils_latest_commit_hash='f431f58dd890ea9dad386233c18b9555182fcb46'
# WORKDIR /git/coreutils
# RUN source '/root/.bashrc' \
#     && git clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch 'https://github.com/uutils/coreutils.git' '/git/coreutils' \
#     && cargo update --verbose || exit 1; \
#     if ! RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --release --verbose; \
#     then git reset --hard "$coreutils_latest_commit_hash" \
#     && echo "$ git reset --hard $shadowsocks_rust_latest_commit_hash" \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo build -j "$(nproc)" --bins --target x86_64-unknown-linux-gnu --release --verbose; \
#     fi; \
#     strip -o "/usr/local/cargo/bin/coreutils" ./target/x86_64-unknown-linux-gnu/release/coreutils \
#     && rm -rf '/git/coreutils' "/usr/local/cargo/bin/cargo" "/usr/local/cargo/bin/cargo-clippy" "/usr/local/cargo/bin/cargo-deb" "/usr/local/cargo/bin/cargo-audit" "/usr/local/cargo/bin/cargo-fmt" "/usr/local/cargo/bin/cargo-miri" "/usr/local/cargo/bin/clippy-driver" "/usr/local/cargo/bin/rls ./rust-analyzer" "/usr/local/cargo/bin/rust-gdb" "/usr/local/cargo/bin/rust-gdbgui" "/usr/local/cargo/bin/rust-lldb" "/usr/local/cargo/bin/rustc" "/usr/local/cargo/bin/rustdoc" "/usr/local/cargo/bin/rustfmt" "/usr/local/cargo/bin/rustup" "/usr/local/cargo/git" "/usr/local/cargo/registry"

FROM quay.io/icecodenew/rust-collection:build_base_debian AS sd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/chmln/sd/commits?per_page=1
ARG sd_latest_commit_hash='ab6827df4e5006d017d1a08524e3183a3708bd6e'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=-crt-static -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-gnu --git 'https://github.com/chmln/sd.git' --verbose \
    && mv ./sd ./sd-stripped
RUN LDFLAGS="-s" \
    && CXXFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && CFLAGS="-O3 -pipe -fexceptions -g0 -grecord-gcc-switches" \
    && export LDFLAGS CXXFLAGS CFLAGS \
    && env \
    && RUSTFLAGS="-C prefer-dynamic=off -C target-cpu=x86-64-v2 -C target-feature=+crt-static" cargo install --bins -j "$(nproc)" --target x86_64-pc-windows-gnu --git 'https://github.com/chmln/sd.git' --verbose \
    && x86_64-w64-mingw32-strip ./sd.exe \
    && strip -p -o ./sd ./sd-stripped \
    && rm -rf ./sd-stripped ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_alpine AS fd
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/sharkdp/fd/releases/latest
# ARG fd_latest_tag_name='v8.1.1'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl fd-find --verbose \
#     && strip ./fd \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_alpine AS bat
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/sharkdp/bat/releases/latest
# ARG bat_latest_tag_name='v0.16.0'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --locked bat --verbose \
#     && strip ./bat \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_alpine AS hexyl
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/sharkdp/hexyl/releases/latest
# ARG hexyl_latest_tag_name='v0.8.0'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hexyl --verbose \
#     && strip ./hexyl \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_alpine AS hyperfine
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/sharkdp/hyperfine/releases/latest
# ARG hyperfine_latest_tag_name='v1.11.0'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hyperfine --verbose \
#     && strip ./hyperfine \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

FROM quay.io/icecodenew/rust-collection:build_base_alpine AS checksec
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/etke/checksec.rs/releases/latest
ARG checksec_rs_latest_tag_name='v0.0.8'
WORKDIR /usr/local/cargo/bin
RUN source '/root/.bashrc' \
    && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl checksec --verbose \
    && strip ./checksec \
    && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

# FROM quay.io/icecodenew/rust-collection:build_base_alpine AS desed
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# # https://api.github.com/repos/SoptikHa2/desed/releases/latest
# ARG desed_latest_tag_name='v1.2.0'
# WORKDIR /usr/local/cargo/bin
# RUN source '/root/.bashrc' \
#     && RUSTFLAGS="-C relocation-model=pic -C prefer-dynamic=off -C target-cpu=x86-64-v2 -C link-arg=-fuse-ld=mold" cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl desed --verbose \
#     && strip ./desed \
#     && rm -rf ./cargo ./cargo-clippy ./cargo-deb ./cargo-audit ./cargo-fmt ./cargo-miri ./clippy-driver ./rls ./rust-analyzer ./rust-gdb ./rust-gdbgui ./rust-lldb ./rustc ./rustdoc ./rustfmt ./rustup "/usr/local/cargo/git" "/usr/local/cargo/registry"

FROM scratch AS assets
COPY --from=shadowsocks-rust /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=boringtun /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=cfnts /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=dog /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=qft /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=websocat /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=rsign2 /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=b3sum /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=ripgrep /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=coreutils /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=sd /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=fd /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=bat /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=hexyl /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=hyperfine /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=fnm /usr/local/cargo/bin /usr/local/cargo/bin/
COPY --from=checksec /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=just /usr/local/cargo/bin /usr/local/cargo/bin/
# COPY --from=desed /usr/local/cargo/bin /usr/local/cargo/bin/

FROM quay.io/icecodenew/alpine:latest AS collection
COPY --from=assets /usr/local/cargo/bin/* /usr/local/cargo/bin/
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# date +%s
# ARG cachebust='1603527789'
ARG TZ='Asia/Taipei'
ENV DEFAULT_TZ ${TZ}
RUN apk update; apk --no-progress --no-cache add \
    bash coreutils curl tzdata; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    cp -f /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime
