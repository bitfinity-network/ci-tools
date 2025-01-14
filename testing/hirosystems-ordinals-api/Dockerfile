FROM ubuntu:24.04

WORKDIR /app
COPY hirosystems-ordinals-api/ordinals-api.sh .
RUN apt update && apt install -y curl
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash
RUN apt install -y nodejs git

# Install ordinals-api
RUN git clone https://github.com/bitfinity-network/ordinals-api-regtest.git && \
  cd ordinals-api-regtest/ && \
  npm install && \
  npm run build && \
  npm run generate:git-info && \
  npm prune --production

EXPOSE 3000 3099

ENTRYPOINT ./ordinals-api.sh
