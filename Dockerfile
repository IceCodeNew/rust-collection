FROM quay.io/icecodenew/rust-collection:build_base AS b3sum
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/BLAKE3-team/BLAKE3/releases/latest
ARG b3sum_latest_tag_name='0.3.7'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl b3sum \
    && strip '/root/.cargo/bin/b3sum'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base AS fd
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/fd/releases/latest
ARG fd_latest_tag_name='v8.1.1'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl fd-find \
    && strip '/root/.cargo/bin/fd'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base AS bat
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/bat/releases/latest
ARG bat_latest_tag_name='v0.16.0'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --locked bat \
    && strip '/root/.cargo/bin/bat'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base AS hexyl
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hexyl/releases/latest
ARG hexyl_latest_tag_name='v0.8.0'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hexyl \
    && strip '/root/.cargo/bin/hexyl'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base AS hyperfine
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/sharkdp/hyperfine/releases/latest
ARG hyperfine_latest_tag_name='v1.11.0'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl hyperfine \
    && strip '/root/.cargo/bin/hyperfine'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base AS fnm
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/Schniz/fnm/releases/latest
ARG fnm_latest_tag_name='v1.22.6'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/Schniz/fnm.git' --tag "$fnm_latest_tag_name" \
    && strip '/root/.cargo/bin/fnm'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base AS checksec
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/etke/checksec.rs/releases/latest
ARG checksec_rs_latest_tag_name='v0.0.8'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl checksec \
    && strip '/root/.cargo/bin/checksec'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/rust-collection:build_base AS boringtun
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# https://api.github.com/repos/cloudflare/boringtun/commits?per_page=1
ARG boringtun_latest_commit_hash='a6d9d059a72466c212fa3055170c67ca16cb935b'
RUN source '/root/.bashrc' \
    && source '/root/.cargo/env' \
    && cargo install --bins -j "$(nproc)" --target x86_64-unknown-linux-musl --git 'https://github.com/cloudflare/boringtun.git' \
    && strip '/root/.cargo/bin/boringtun'; \
    rm -rf "/root/.cargo/registry" || exit 0

FROM quay.io/icecodenew/alpine:edge AS collection
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# date +%s
ARG cachebust='1603527789'
ARG TZ='Asia/Taipei'
ENV DEFAULT_TZ ${TZ}
COPY --from=b3sum /root/.cargo/bin /root/.cargo/bin/
COPY --from=fd /root/.cargo/bin /root/.cargo/bin/
COPY --from=bat /root/.cargo/bin /root/.cargo/bin/
COPY --from=hexyl /root/.cargo/bin /root/.cargo/bin/
COPY --from=hyperfine /root/.cargo/bin /root/.cargo/bin/
COPY --from=fnm /root/.cargo/bin /root/.cargo/bin/
COPY --from=checksec /root/.cargo/bin /root/.cargo/bin/
COPY --from=boringtun /root/.cargo/bin /root/.cargo/bin/
RUN apk update; apk --no-progress --no-cache add \
    bash coreutils curl tzdata; \
    apk --no-progress --no-cache upgrade; \
    rm -rf /var/cache/apk/*; \
    cp -f /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime
