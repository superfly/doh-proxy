# ------------------------------------------------------------------------------
# Cargo Build Stage
# ------------------------------------------------------------------------------

FROM rust:latest as cargo-build

ARG VERSION=0.1.19

RUN apt-get update

RUN apt-get install musl-tools -y

RUN rustup target add x86_64-unknown-linux-musl

RUN RUSTFLAGS=-Clinker=musl-gcc cargo install doh-proxy --version $VERSION --root /usr/local/ --target=x86_64-unknown-linux-musl

# ------------------------------------------------------------------------------
# Final Stage
# ------------------------------------------------------------------------------

FROM alpine:3.10

RUN apk add --no-cache libgcc runit shadow curl

COPY --from=cargo-build /usr/local/bin /usr/local/bin

RUN useradd doh-proxy

USER doh-proxy

ENV LISTEN=0.0.0.0:8080
ENV RESOLVER=9.9.9.9:53

RUN /usr/local/bin/doh-proxy --version

CMD ["sh", "-c", "/usr/local/bin/doh-proxy --listen-address $LISTEN --server-address $RESOLVER"]