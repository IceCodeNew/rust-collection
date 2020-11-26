# syntax = docker/dockerfile:1.0-experimental
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
    --name "ss-rust.tar.xz" \
    --file "/usr/local/cargo/bin/ss-rust.tar.xz"; \
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
    github-release upload \
    --user IceCodeNew \
    --repo rust-collection \
    --tag "$tag_name" \
    --name "boringtun" \
    --file "/usr/local/cargo/bin/boringtun"
