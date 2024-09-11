# Testing docker images

Images used for integration testing of Bitfinity projects.

All images in this folder have to be built from the parent (i.e. `testing`) directory.

Use the provided `docker-compose.yml` file to build the images and as a reference on how to use them.

# Images

## testing-local-ssl-proxy

A [local-ssl-proxy](https://www.npmjs.com/package/local-ssl-proxy) that allow HTTPS calls to localhost.

By default it exposes the port 8002 and forwards the calls to the local port 8545.


## testing-ordinals-ord

An [ord](https://github.com/ordinals/ord) index.


## testing-hirosystems-ordhook
The [ordhook](https://github.com/hirosystems/ordhook) indexer.

## testing-hirosystems-ordinals-api
The [Bitcoin Ordinals API](https://github.com/hirosystems/ordinals-api) 

## testing-hirosystems-ordinals-explorer
The [Bitcoin Ordinals Explorer](https://github.com/hirosystems/ordinals-explorer)


