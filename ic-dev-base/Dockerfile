FROM rust:1.67-slim-bullseye as base

ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/workspace
ENV HOME=/workspace

WORKDIR $WORK_DIR

# Dfinity SDK
ARG motoko_version=0.8.2
ARG dfx_version=0.13.1
ARG DFX_DEV_IDENTITY=ic_dev_identity
ARG DFX_DEV_ACCOUNT_IDENTITY=ic_dev_account

ENV DFX_DEV_IDENTITY=${DFX_DEV_IDENTITY}
ENV DFX_DEV_ACCOUNT_IDENTITY=${DFX_DEV_ACCOUNT_IDENTITY}

COPY identities ./identities

RUN apt-get update && apt-get -y full-upgrade \
    && apt-get install -y pkg-config curl git gzip unzip tar pigz build-essential cmake \ 
    libssl-dev clang liblmdb-dev libunwind-dev csvkit jq python3 pipenv lcov \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --upgrade pip

# protoc
# latest version # echo $(curl -s "https://api.github.com/repos/protocolbuffers/protobuf/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
# note that git tag must be available for provided version
ARG PROTOC_VERSION=21.12
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
    && rustup component add llvm-tools-preview \
    && cargo install ic-wasm cargo-audit cargo-llvm-cov grcov

# getfoundry.sh
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="$PATH:$HOME/.foundry/bin"
RUN foundryup

# motoko & quill
RUN curl -fsSL https://github.com/dfinity/motoko/releases/download/${motoko_version}/motoko-linux64-${motoko_version}.tar.gz \
    | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin \
    && curl -OL https://github.com/dfinity/quill/releases/download/0.3.0/quill-linux-x86_64 \
    && chmod +x quill-linux-x86_64 && mv quill-linux-x86_64 /usr/local/bin/quill

# dfx and import test identities
RUN DFX_VERSION=${dfx_version} sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)" \
    && dfx identity import --disable-encryption $DFX_DEV_ACCOUNT_IDENTITY ./identities/$DFX_DEV_ACCOUNT_IDENTITY/identity.pem \
    && dfx identity import --disable-encryption $DFX_DEV_IDENTITY ./identities/$DFX_DEV_IDENTITY/identity.pem \
    && dfx identity use $DFX_DEV_IDENTITY \
    && rm -rf $CARGO_HOME/registry \
    && chmod -R 0777 .cache \
    && chmod -R 0777 .config \
    && chown root:root /usr/local/bin/* \
    && chmod -R 0755 /usr/local/bin
