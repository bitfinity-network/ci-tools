# Images to run CI pipelines

## ic-dev-base

Core image for all our pipelines.
It contains:

* rust, cargo, clippy, etc.
* DFX with Motoko
* ic-wasm
* python3
* `jq` to modify json files easily

DFX installation has pre-defined identities which names are stored in env variables: `DFX_DEV_IDENTITY` and `DFX_DEV_ACCOUNT_IDENTITY`.

`WORK_DIR` env points to work/home directory. Do not rely on `HOME` because this variable could be changed by the GitHub CI.


## ic-bin

This is where we are building modules to set up NNS with.
We are using our fork of the IC repository with some additional patches.
Ideally we should compile modules from IC directrly.

Also this image include our ifx tool to upload binaries directly into canisters.


## ic-dev-full

Based on **ic-dev-base** and includes binaries from the **ic-bin**.

Image features:

* Pre configured NNS environment with dfx.json located in `WORK_DIR` with ledger-test canister
* nns-bin-init cli tool installed
* Configured nginx proxy:
  * Serves at 8001
  * Proxy all requests to DFX 8000
  * `/static/` URI show all files in directory defined in `PUBLIC_DIR` env var.
  * `/_/dashboard` URI proxy request to DFX replica dashboard at 8080 if it is available.

Also you can configure and run your own DFX environment from other folder.

In order to launch image with proxy launch DFX in background and then start nginx.
```
CMD (dfx start --background && nginx)
```



