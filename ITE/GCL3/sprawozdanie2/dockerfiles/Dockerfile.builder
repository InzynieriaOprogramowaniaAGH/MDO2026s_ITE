FROM rust:1.85-slim-bookworm


RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        pkg-config \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN cargo install cargo-deb --version 3.6.2
WORKDIR /app


RUN git clone --depth 1 --branch 14.1.1 https://github.com/BurntSushi/ripgrep.git .
RUN cargo build --release

#fix
RUN mkdir -p deployment/deb && \
    ./target/release/rg --generate man > deployment/deb/rg.1 && \
    ./target/release/rg --generate complete-bash > deployment/deb/rg.bash && \
    ./target/release/rg --generate complete-fish > deployment/deb/rg.fish && \
    ./target/release/rg --generate complete-zsh > deployment/deb/_rg && \
    ./target/release/rg --generate complete-powershell > deployment/deb/_rg.ps1
# - 


RUN cargo deb --no-build
CMD ["./target/release/rg", "--version"]
