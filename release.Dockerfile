# syntax=docker.io/docker/dockerfile-upstream:labs
FROM quay.io/icecodenew/rust-collection:latest AS rust_upload
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY got_github_release.sh /tmp/got_github_release.sh
WORKDIR /usr/local/cargo/bin
# import secret:
RUN --mount=type=secret,id=GIT_AUTH_TOKEN,dst=/tmp/secret_token export GITHUB_TOKEN="$(cat /tmp/secret_token)" \
    && bash /tmp/got_github_release.sh \
    && export tag_name="$(TZ=':Asia/Taipei' date +%F-%H-%M-%S)" \
    && github-release release \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "$tag_name"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "4limit-mem-server-only-ss-rust-linux-gnu-x64.tar.gz" \
    --file "/usr/local/cargo/bin/4limit-mem-server-only-ss-rust-linux-gnu-x64.tar.gz"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "ss-rust-linux-gnu-x64.tar.xz" \
    --file "/usr/local/cargo/bin/ss-rust-linux-gnu-x64.tar.xz"; \
    # github-release upload \
    # --user IceCodeNew \
    # --repo rust-collection \
    # --tag "$tag_name" \
    # --name "ss-rust-linux-arm-musleabi5-x32.tar.gz" \
    # --file "/usr/local/cargo/bin/ss-rust-linux-arm-musleabi5-x32.tar.gz"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "ss-rust-win-gnu-x64.zip" \
    --file "/usr/local/cargo/bin/ss-rust-win-gnu-x64.zip"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "boringtun-linux-gnu-x64" \
    --file "/usr/local/cargo/bin/boringtun-linux-gnu-x64"; \
    # github-release upload \
    # --user IceCodeNew \
    # --repo rust-collection \
    # --tag "$tag_name" \
    # --name "boringtun-linux-arm-musleabi5-x32" \
    # --file "/usr/local/cargo/bin/boringtun-linux-arm-musleabi5-x32"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "rsign" \
    --file "/usr/local/cargo/bin/rsign"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "rsign.exe" \
    --file "/usr/local/cargo/bin/rsign.exe"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "b3sum" \
    --file "/usr/local/cargo/bin/b3sum"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "b3sum.exe" \
    --file "/usr/local/cargo/bin/b3sum.exe"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "ripgrep" \
    --file "/usr/local/cargo/bin/rg"; \
    # export pcre2_deb_filename="$(grep -E 'pcre2_.+_amd64.deb' <(find /build_root -maxdepth 1 -type f -printf '%f\n'))"; \
    # github-release upload \
    # --user IceCodeNew \
    # --repo rust-collection \
    # --tag "$tag_name" \
    # --name "$pcre2_deb_filename" \
    # --file "/build_root/$pcre2_deb_filename"; \
    # github-release upload \
    # --user IceCodeNew \
    # --repo rust-collection \
    # --tag "$tag_name" \
    # --name "coreutils" \
    # --file "/usr/local/cargo/bin/coreutils"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "sd" \
    --file "/usr/local/cargo/bin/sd"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "sd.exe" \
    --file "/usr/local/cargo/bin/sd.exe"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "fd" \
    --file "/usr/local/cargo/bin/fd"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "bat" \
    --file "/usr/local/cargo/bin/bat"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "hexyl" \
    --file "/usr/local/cargo/bin/hexyl"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "hyperfine" \
    --file "/usr/local/cargo/bin/hyperfine"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "fnm" \
    --file "/usr/local/cargo/bin/fnm"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "checksec" \
    --file "/usr/local/cargo/bin/checksec"; \
    # github-release upload \
    # --user IceCodeNew \
    # --repo rust-collection \
    # --tag "$tag_name" \
    # --name "cfnts" \
    # --file "/usr/local/cargo/bin/cfnts"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "dog" \
    --file "/usr/local/cargo/bin/dog"; \
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "websocat" \
    --file "/usr/local/cargo/bin/websocat"
    # github-release upload \
    # --user IceCodeNew \
    # --repo rust-collection \
    # --tag "$tag_name" \
    # --name "just" \
    # --file "/usr/local/cargo/bin/just"; \
    # github-release upload \
    # --user IceCodeNew \
    # --repo rust-collection \
    # --tag "$tag_name" \
    # --name "desed" \
    # --file "/usr/local/cargo/bin/desed"
