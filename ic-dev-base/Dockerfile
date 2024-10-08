FROM rust:1.77-slim-bullseye as base

ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/workspace
ENV HOME=/workspace

WORKDIR $WORK_DIR

# Dfinity SDK
## https://github.com/dfinity/quill/releases
ARG quill_version=v0.4.4
## https://github.com/dfinity/motoko/releases
ARG motoko_version=0.11.1
## https://github.com/dfinity/sdk/releases
ARG dfx_version=0.19.0
ARG nvm_version=0.39.7

ARG DFX_DEV_IDENTITY=ic_dev_identity
ARG DFX_DEV_ACCOUNT_IDENTITY=ic_dev_account

ENV DFX_DEV_IDENTITY=${DFX_DEV_IDENTITY}
ENV DFX_DEV_ACCOUNT_IDENTITY=${DFX_DEV_ACCOUNT_IDENTITY}

COPY identities ./identities

RUN apt-get update && apt-get -y full-upgrade \
    && apt-get install -y pkg-config curl git gzip unzip tar pigz build-essential cmake \ 
    libssl-dev clang liblmdb-dev libunwind-dev csvkit jq python3 pipenv lcov gcc-multilib \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --upgrade pip

# protoc
# latest version # echo $(curl -s "https://api.github.com/repos/protocolbuffers/protobuf/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
# note that git tag must be available for provided version
ARG PROTOC_VERSION=26.1
ENV PROTOC_INCLUDE=${WORK_DIR}/protoc
RUN curl -Lo protoc.zip "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip"
RUN unzip -q protoc.zip bin/protoc -d /usr/local && chmod a+x /usr/local/bin/protoc && rm protoc.zip
RUN protoc --version

RUN export URI="https://raw.githubusercontent.com/protocolbuffers/protobuf/v${PROTOC_VERSION}/src/google/protobuf" && \
    curl --create-dirs -O --output-dir "${PROTOC_INCLUDE}/google/protobuf" "${URI}/empty.pb.h" && \
    curl --create-dirs -O --output-dir "${PROTOC_INCLUDE}/google/protobuf" "${URI}/empty.proto" && \
    curl --create-dirs -O --output-dir "${PROTOC_INCLUDE}/google/protobuf" "${URI}/empty.pb.cc"
# this would mean that a file can be found at $PROTOC_INCLUDE/google/protobuf/empty.*

# rust & related toolchain
RUN rustup component add clippy rustfmt \
    && rustup target add wasm32-unknown-unknown \
    && rustup target add i686-unknown-linux-gnu \
    && rustup component add llvm-tools-preview \
    && cargo install --version 0.10.1 icx-proxy \
    && cargo install ic-wasm cargo-audit cargo-llvm-cov grcov

# NVM
# https://github.com/nvm-sh/nvm/releases
ENV NVM_SH=/workspace/.nvm/nvm.sh
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash
RUN echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" \n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc

# getfoundry.sh
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="$PATH:$HOME/.foundry/bin"
RUN foundryup

# motoko & quill
RUN curl -fsSL https://github.com/dfinity/motoko/releases/download/${motoko_version}/motoko-Linux-x86_64-${motoko_version}.tar.gz \
    | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin \
    && curl -OL https://github.com/dfinity/quill/releases/download/${quill_version}/quill-linux-x86_64 \
    && chmod +x quill-linux-x86_64 && mv quill-linux-x86_64 /usr/local/bin/quill

# dfx and import test identities
ENV DFXVM_INIT_YES=true

RUN DFX_VERSION=${dfx_version} sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

RUN . "$HOME/.local/share/dfx/env" \
    && dfx identity import --disable-encryption $DFX_DEV_ACCOUNT_IDENTITY ./identities/$DFX_DEV_ACCOUNT_IDENTITY/identity.pem \
    && dfx identity import --disable-encryption $DFX_DEV_IDENTITY ./identities/$DFX_DEV_IDENTITY/identity.pem \
    && dfx identity use $DFX_DEV_IDENTITY

# Fix DFX/Github init paths issues
ENV PATH="$HOME/.local/share/dfx/bin:$PATH"
RUN sed -i 's/\$HOME/\/workspace/g' /workspace/.bashrc \
    && sed -i 's/\$HOME/\/workspace/g' /workspace/.profile \
    && sed -i 's/\$HOME/\/workspace/g' /workspace/.local/share/dfx/env

# Clean stuff
RUN rm -rf $CARGO_HOME/registry \
    && chmod -R 0777 .cache \
    && chmod -R 0777 .config \
    && chown root:root /usr/local/bin/* \
    && chmod -R 0755 /usr/local/bin
