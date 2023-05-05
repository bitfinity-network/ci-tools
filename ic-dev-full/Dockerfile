ARG BIN_IMAGE=ghcr.io/infinity-swap/ic-bin:latest
ARG BASE_IMAGE=ghcr.io/infinity-swap/ic-dev-base:latest

FROM debian:bullseye as retesteth_build
# Please note that theese tags must be mutually compatible
ARG RETESTETH_TAG=v0.3.0-shanghai
ARG ETH_TESTS_TAG=v12

WORKDIR /retesteth

RUN apt-get update
RUN apt-get install -y git cmake clang

RUN git clone --depth 1 --branch $ETH_TESTS_TAG https://github.com/ethereum/tests.git tests && rm -rf ./tests/.git &&\
    git clone --depth 1 --branch $RETESTETH_TAG https://github.com/ethereum/retesteth.git git

RUN cd git && mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j4

FROM $BIN_IMAGE as ic_bin
FROM $BASE_IMAGE

ARG WORK_DIR=$WORK_DIR
ENV DFX_WASMS_DIR=${WORK_DIR}/wasm
ENV DFX_DID_DIR=${WORK_DIR}/candid
ENV DFX_NEURONS_DIR=${WORK_DIR}/neurons
ENV IC_HOST=0.0.0.0:8000
ENV IC_URI=http://localhost:8000
ENV PUBLIC_DIR=/workspace/static

WORKDIR $WORK_DIR

RUN mkdir -p $DFX_WASMS_DIR $DFX_DID_DIR $PUBLIC_DIR
    
COPY neurons/* ${DFX_NEURONS_DIR}/
COPY dfx.json ${WORK_DIR}
COPY bin/* /usr/local/bin/

# Pack external binaries
COPY --from=ic_bin --chown=root:root /ic/wasm $WORK_DIR/wasm
COPY --from=ic_bin --chown=root:root /ic/bin/* /usr/local/bin/

# NGINX
RUN apt-get update
RUN echo "Y" | apt-get -y install nginx-light
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --chown=root:root nginx.conf /etc/nginx/nginx.conf

# Adding retesteth
COPY --from=retesteth_build --chown=root:root /retesteth/git/build/retesteth/retesteth /usr/local/bin/
COPY --from=retesteth_build --chown=root:root /retesteth/git/build/retesteth/tests $WORK_DIR/ethereum_tests
RUN retesteth -t BlockchainTests -- --clients evmc || :

# DFX
RUN cd $DFX_WASMS_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/wasm/ledger-canister-min.wasm && \
    cd $DFX_DID_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/candid/ledger-min.did
    
# Reference CLI command to add something into dfx
RUN J=$(jq ".canisters += {\"ledger-test\":{\"wasm\":\"$DFX_WASMS_DIR/ledger-canister-min.wasm\",\"candid\":\"$DFX_DID_DIR/ledger-min.did\",\"type\":\"custom\"}}" ./dfx.json) && echo "$J" > ./dfx.json

# Finishing stuff
RUN chmod -R 0777 $DFX_WASMS_DIR $DFX_DID_DIR && \
    chmod -R 0755 /usr/local/bin
    
RUN dfx start --clean --background && nns-init.sh && dfx stop

# All workspace should be accessible for any user
RUN chmod -R 0777 ./ && \
    # But we can not do it for DFX directory
    chmod -R 0770 .dfx

EXPOSE 8000

CMD (dfx start --host $IC_HOST --background && nginx)
