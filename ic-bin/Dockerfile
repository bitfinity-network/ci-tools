ARG BASE_IMAGE=ghcr.io/infinity-swap/ic-dev-base:latest

FROM ${BASE_IMAGE} as ic_builder

ARG IC_BUILD_BRANCH=rebased-2022-02-17 
ARG IC_REPO=https://github.com/infinity-swap/ic.git
# Just a hack to use it in next ENV instructions
ARG WORK_DIR=$WORK_DIR
WORKDIR $WORK_DIR

RUN mkdir -p /ic /ic/wasm /ic/bin

RUN git clone --depth 1 ${IC_REPO} --branch=${IC_BUILD_BRANCH} --single-branch ic

# Env hack for IC builds
ENV ARTIFACTS_DIR=${WORK_DIR}/ic/artifacts
ENV IC_RS_WD=${WORK_DIR}/ic/rs
ENV CARGO_TARGET_DIR=${WORK_DIR}/ic/rs/target

# Building NNS tool
RUN cd ${IC_RS_WD} && \
    RUST_BACKTRACE=full cargo build --release --bin ic-nns-init
 
RUN ls ${IC_RS_WD}/target/release && \
    mv ${IC_RS_WD}/target/release/ic-nns-init /ic/bin

# Building  NNS canisters
RUN cd ic && \
    cat ./gitlab-ci/src/requirements.txt | grep -v PyYAML > requirements.txt && \
    pip install -r  requirements.txt && \
    sed -i 's/_check_canisters_size(artifacts_dir=default_artifacts_dir)/_check_canisters_size(artifacts_dir)/g' ./gitlab-ci/src/job_scripts/cargo_build_canisters.py && \
    python3 ./gitlab-ci/tools/job-driver.py cargo-build-canisters "${ARTIFACTS_DIR}"

RUN cd ${ARTIFACTS_DIR} && find *.gz | xargs -I {} gzip -df {} 
RUN mv ${ARTIFACTS_DIR}/*.wasm /ic/wasm && ls -la /ic/wasm

# IFX
ENV CARGO_TARGET_DIR='target'
RUN git clone https://github.com/infinity-swap/ifx  && \
    cd ifx && \
    cargo build --release && \
    cp target/release/ifx /ic/bin

RUN echo "!!! Bin Output !!!" && ls -lR /ic

# Now put files into scratch based image
FROM scratch as ic_bin
COPY --from=ic_builder /ic /ic
