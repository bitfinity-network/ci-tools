FROM rust:1.69-slim-bullseye as ic_builder

ARG IC_BUILD_BRANCH=patched-rc--2023-06-01_23-01
ARG IC_REPO=https://github.com/infinity-swap/ic.git

WORKDIR /build

RUN apt-get update && apt-get install -y \
    curl git gzip unzip tar pigz \
    build-essential pkg-config clang libssl-dev libunwind-dev libusb-1.0-0-dev zlib1g-dev

RUN mkdir -p /ic /ic/wasm /ic/bin

RUN git clone --depth 1 ${IC_REPO} --branch=${IC_BUILD_BRANCH} --single-branch ic

RUN curl -LO  https://github.com/bazelbuild/bazel/releases/download/5.4.0/bazel-5.4.0-installer-linux-x86_64.sh \
    && bash bazel-5.4.0-installer-linux-x86_64.sh

RUN cd "/usr/local/lib/bazel/bin" &&  mkdir bazel-buildbuddy-io && cd "bazel-buildbuddy-io" \
    && curl -fLO https://github.com/buildbuddy-io/bazel/releases/download/5.0.10/bazel-5.0.10-linux-x86_64  \
    && mv bazel-5.0.10-linux-x86_64 5.0.10-linux-x86_64 && chmod +x 5.0.10-linux-x86_64 

RUN bazel version

RUN cd ic && touch /.dockerenv && echo -ne '\n' | gitlab-ci/container/build-ic.sh --binaries --no-release

RUN cd ic/artifacts/release/ && find *.gz | xargs -I {} gzip -df {} 
RUN mv ic/artifacts/release/* /ic/bin

RUN cd ic && touch /.dockerenv && echo -ne '\n' | gitlab-ci/container/build-ic.sh --canisters --no-release

RUN cd ic/artifacts/canisters/ && find *.gz | xargs -I {} gzip -df {} 
RUN mv ic/artifacts/canisters/* /ic/wasm

# Building IFX
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s - "-y"

ENV CARGO_TARGET_DIR='target'
RUN git clone https://github.com/infinity-swap/ifx  && cd ifx \
    && cargo build --release \
    && cp target/release/ifx /ic/bin

RUN echo "!!! Bin Output !!!" && ls -lR /ic

# Now put files into scratch based image
FROM scratch as ic_bin
COPY --from=ic_builder /ic /ic
