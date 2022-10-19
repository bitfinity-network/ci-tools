FROM rust:1.64-slim-bullseye as base

ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/workspace
ENV HOME=/workspace

WORKDIR $WORK_DIR
# Dfinity SDK
ARG motoko_version=0.7.0
ARG dfx_version=0.11.2
ARG DFX_DEV_IDENTITY=ic_dev_identity
ARG DFX_DEV_ACCOUNT_IDENTITY=ic_dev_account

ENV DFX_DEV_IDENTITY=${DFX_DEV_IDENTITY}
ENV DFX_DEV_ACCOUNT_IDENTITY=${DFX_DEV_ACCOUNT_IDENTITY}

COPY identities ./

RUN apt-get update && \
    apt-get -y full-upgrade && \
    apt-get install -y pkg-config curl git gzip tar pigz build-essential cmake \ 
    libssl-dev clang liblmdb-dev libunwind-dev csvkit jq python3 pipenv lcov && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    python3 -m pip install --upgrade pip && \
    # install rust & related toolchain
    rustup component add clippy rustfmt && \
    rustup target add wasm32-unknown-unknown && \
    rustup component add llvm-tools-preview && \
    cargo install ic-cdk-optimizer && \
    cargo install cargo-audit && \
    cargo install cargo-llvm-cov && \
    cargo install grcov && \
    # install motoko & quill
    curl -fsSL https://github.com/dfinity/motoko/releases/download/${motoko_version}/motoko-linux64-${motoko_version}.tar.gz \
    | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin \
    && curl -OL https://github.com/dfinity/quill/releases/download/0.3.0/quill-linux-x86_64 \
    && chmod +x quill-linux-x86_64 && mv quill-linux-x86_64 /usr/local/bin/quill \
    # install dfx and import test identities
    && DFX_VERSION=${dfx_version} sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)" \
    && dfx identity import --disable-encryption $DFX_DEV_ACCOUNT_IDENTITY ./identities/$DFX_DEV_ACCOUNT_IDENTITY/identity.pem \
    && dfx identity import --disable-encryption $DFX_DEV_IDENTITY ./identities/$DFX_DEV_IDENTITY/identity.pem \
    && dfx identity use $DFX_DEV_IDENTITY \
    && rm -rf $CARGO_HOME/registry \
    && chmod -R 0777 .cache \
    && chmod -R 0777 .config \
    && chown root:root /usr/local/bin/* \
    && chmod -R 0755 /usr/local/bin
