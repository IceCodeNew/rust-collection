FROM alpine:edge AS rust-base
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# https://api.github.com/repos/slimm609/checksec.sh/releases/latest
ARG checksec_latest_tag_name='2.4.0'
# https://api.github.com/repos/IceCodeNew/myrc/commits?per_page=1&path=.bashrc
ARG bashrc_latest_commit_hash='dffed49d1d1472f1b22b3736a5c191d74213efaa'
# https://api.github.com/repos/rust-lang/rust/releases/latest
ARG rust_latest_tag_name='1.47.0'
RUN apk update; apk --no-progress --no-cache add \
    apk-tools bash binutils build-base ca-certificates coreutils curl dos2unix dpkg file gettext-tiny-dev grep libarchive-tools libedit-dev libedit-static lld musl musl-dev musl-libintl musl-utils ncurses ncurses-dev ncurses-static openssl pkgconf rustup; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    update-alternatives --install /usr/local/bin/ld ld /usr/bin/lld 100; \
    update-alternatives --auto ld; \
    curl -sSL4q --retry 5 --retry-delay 10 --retry-max-time 60 -o '/usr/bin/checksec' "https://raw.githubusercontent.com/slimm609/checksec.sh/${checksec_latest_tag_name}/checksec"; \
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

FROM rust-base AS fd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/fd/releases/latest
ARG fd_latest_tag_name='v8.1.1'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --target x86_64-unknown-linux-musl fd-find \
    && strip '/root/.cargo/bin/fd'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM rust-base AS bat
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/bat/releases/latest
ARG bat_latest_tag_name='v0.16.0'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --target x86_64-unknown-linux-musl --locked bat \
    && strip '/root/.cargo/bin/bat'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM rust-base AS hexyl
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hexyl/releases/latest
ARG hexyl_latest_tag_name='v0.8.0'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --target x86_64-unknown-linux-musl hexyl \
    && strip '/root/.cargo/bin/hexyl'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM rust-base AS hyperfine
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hyperfine/releases/latest
ARG hyperfine_latest_tag_name='v1.11.0'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --target x86_64-unknown-linux-musl hyperfine \
    && strip '/root/.cargo/bin/hyperfine'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM rust-base AS boringtun
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/cloudflare/boringtun/commits?per_page=1
ARG boringtun_latest_commit_hash='a6d9d059a72466c212fa3055170c67ca16cb935b'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --target x86_64-unknown-linux-musl --git 'https://github.com/cloudflare/boringtun.git' \
    && strip '/root/.cargo/bin/boringtun'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM scratch AS rust-collection
# date +%s
ARG cachebust='1603527789'
COPY --from=b3sum /root/.cargo/bin/b3sum /root/go/bin/b3sum
COPY --from=fd /root/.cargo/bin/fd /root/go/bin/fd
COPY --from=bat /root/.cargo/bin/bat /root/go/bin/bat
COPY --from=hexyl /root/.cargo/bin/hexyl /root/go/bin/hexyl
COPY --from=hyperfine /root/.cargo/bin/hyperfine /root/go/bin/hyperfine
COPY --from=boringtun /root/.cargo/bin/boringtun /root/go/bin/boringtun
