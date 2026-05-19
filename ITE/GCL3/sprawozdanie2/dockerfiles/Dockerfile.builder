
FROM rust:1.83-slim-bookworm


RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        pkg-config \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN cargo install cargo-deb --version 3.6.2
WORKDIR /app


RUN git clone --depth 1 --branch 14.1.1 https://github.com/BurntSushi/ripgrep.git .
RUN cargo build --release
RUN cargo deb --no-build
CMD ["./target/release/rg", "--version"]
