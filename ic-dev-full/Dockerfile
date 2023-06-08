ARG BIN_IMAGE=ghcr.io/infinity-swap/ic-bin:latest
# ARG BASE_IMAGE=ghcr.io/infinity-swap/ic-dev-base:latest
ARG BASE_IMAGE=dev:ic-base

FROM $BIN_IMAGE as ic_bin
FROM $BASE_IMAGE

ARG WORK_DIR=$WORK_DIR
ENV DFX_WASMS_DIR=${WORK_DIR}/wasm
ENV DFX_DID_DIR=${WORK_DIR}/candid
ENV DFX_NEURONS_DIR=${WORK_DIR}/neurons
ENV IC_HOST=0.0.0.0:8080
ENV IC_URI=http://localhost:8080
ENV PUBLIC_DIR=/workspace/static

WORKDIR $WORK_DIR

RUN mkdir -p $DFX_WASMS_DIR $DFX_DID_DIR $PUBLIC_DIR
    
COPY neurons/* ${DFX_NEURONS_DIR}/
COPY dfx.json ${WORK_DIR}
COPY networks.json ${WORK_DIR}/.config/dfx
COPY bin/* /usr/local/bin/

# NGINX
RUN apt-get update
RUN echo "Y" | apt-get -y install nginx-light
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --chown=root:root nginx.conf /etc/nginx/nginx.conf

# Unpack pre-built resources
COPY --from=ic_bin --chown=root:root /ic/wasm $WORK_DIR/wasm
COPY --from=ic_bin --chown=root:root /ic/bin/ifx /usr/local/bin/
COPY --from=ic_bin --chown=root:root /ic/bin/ic-nns-init /usr/local/bin/

# DFX
RUN cd $DFX_WASMS_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/wasm/ledger-canister-min.wasm && \
    cd $DFX_DID_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/candid/ledger-min.did
    
# Reference CLI command to add something into dfx
RUN J=$(jq ".canisters += {\"ledger-test\":{\"wasm\":\"$DFX_WASMS_DIR/ledger-canister-min.wasm\",\"candid\":\"$DFX_DID_DIR/ledger-min.did\",\"type\":\"custom\"}}" ./dfx.json) && echo "$J" > ./dfx.json

# Finishing stuff
RUN chmod -R 0777 $DFX_WASMS_DIR $DFX_DID_DIR && \
    chmod -R 0755 /usr/local/bin ${WORK_DIR}/.config

# Disable creating NNS canisters for now    
# RUN dfx start --clean --background && nns-init.sh && dfx stop

# All workspace should be accessible for any user
RUN chmod -R 0777 ./ && \
    # But we can not do it for DFX directory
    mkdir -p .dfx && chmod -R 0770 .dfx

# 8080 port required to dfx nns install to work
EXPOSE 8080

CMD (dfx start --host $IC_HOST --background && nginx)
