FROM rust:latest AS builder

RUN apt-get update && apt-get install -y cmake clang

WORKDIR /repo

# When updating commit, update it both in `fetch origin` and `checkout` command
RUN git clone https://github.com/MystenLabs/sui.git /repo && \
  cd /repo && \
  git fetch origin 9254fba702bf111d34424f55dc5c3ee0506bc4e1 && \
  git checkout 9254fba702bf111d34424f55dc5c3ee0506bc4e1

RUN cargo build --release --bin sui-bridge

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y libjemalloc-dev ca-certificates curl

# Use jemalloc as memory allocator
#ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so
#ARG PROFILE=release

WORKDIR /opt

COPY --from=builder /repo/target/release/sui-bridge .

ENTRYPOINT ["/opt/sui-bridge"]
