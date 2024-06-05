FROM rust:latest AS builder

RUN apt-get update && apt-get install -y cmake clang

WORKDIR /repo

RUN git clone https://github.com/MystenLabs/sui.git /repo && \
  cd /repo && \
  git fetch origin 7a29f1246f5ebb4d642de451c600f63157562545 && \
  git checkout 7a29f1246f5ebb4d642de451c600f63157562545

RUN cargo build --release --bin sui-bridge

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y libjemalloc-dev ca-certificates curl

# Use jemalloc as memory allocator
#ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so
#ARG PROFILE=release

WORKDIR /opt

COPY --from=builder /repo/target/release/sui-bridge .

ENTRYPOINT ["/opt/sui-bridge"]
