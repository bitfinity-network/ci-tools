#!/usr/bin/env bash

echo "Ord version: $(ord --version)"

rm -rf /data/*
mkdir -p /data

ord -r --index-runes --bitcoin-rpc-url=http://bitcoind:18443 server --http-port=8000
