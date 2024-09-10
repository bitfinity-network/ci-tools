FROM rust:slim-bookworm as builder

RUN apt-get update -y && apt-get install -y build-essential

RUN cargo install candid-extractor
RUN cargo install ic-wasm
# TO BE FIXED: https://infinityswap.atlassian.net/browse/EPROD-958
RUN cargo install icx-proxy --version 0.10.1


FROM ubuntu:24.04 AS runtime

COPY --from=builder /usr/local/cargo/bin/candid-extractor /candid-extractor
COPY --from=builder /usr/local/cargo/bin/ic-wasm /ic-wasm
COPY --from=builder /usr/local/cargo/bin/icx-proxy /icx-proxy

EXPOSE 8545
