ARG BASE_IMAGE=ghcr.io/infinity-swap/ic-dev-base:latest

FROM ${BASE_IMAGE} as ic_builder

ARG IC_BUILD_BRANCH=patched-rc--2022-09-30_18-31
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

# Install python deps
RUN cd ic && \
    cat ./gitlab-ci/src/requirements.txt | grep -v PyYAML > requirements.txt && \
    pip install -r requirements.txt

# Building  NNS canisters
RUN cd ic && \
    sed -i 's/_check_canisters_size(artifacts_dir=default_artifacts_dir)/_check_canisters_size(artifacts_dir)/g' ./gitlab-ci/src/job_scripts/cargo_build_canisters.py && \
    python3 ./gitlab-ci/tools/job-driver.py cargo-build-canisters "${ARTIFACTS_DIR}"

RUN cd ${ARTIFACTS_DIR} && find *.gz | xargs -I {} gzip -df {} 
RUN mv ${ARTIFACTS_DIR}/*.wasm /ic/wasm && ls -la /ic/wasm

# Building NNS tool
RUN cd ${IC_RS_WD} && \
    RUST_BACKTRACE=full cargo build --release --bin ic-nns-init

RUN ls ${IC_RS_WD}/target/release && \
    mv ${IC_RS_WD}/target/release/ic-nns-init /ic/bin

# This python script prepares binaries in dfinity CI
# in order to run it properly here should investigate:
# - gitlab-ci/src/artifacts/collector.py
# - gitlab-ci/src/artifacts/collect_build_binaries.py
# - gitlab-ci/src/ci.py
#
# RUN cd ./ic && \
#     mkdir -p ./artifacts && \
#     cd ./gitlab-ci/src && \
#     python3 -m artifacts.collect_build_binaries artifacts ic-nns-init

# Building IFX
ENV CARGO_TARGET_DIR='target'
RUN git clone https://github.com/infinity-swap/ifx  && \
    cd ifx && \
    cargo build --release && \
    cp target/release/ifx /ic/bin

RUN echo "!!! Bin Output !!!" && ls -lR /ic

# Now put files into scratch based image
FROM scratch as ic_bin
COPY --from=ic_builder /ic /ic
