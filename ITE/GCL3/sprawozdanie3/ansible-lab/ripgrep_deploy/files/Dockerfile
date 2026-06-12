FROM debian:trixie-slim
COPY ripgrep.deb /tmp/ripgrep.deb
RUN apt-get update \
 && apt-get install -y /tmp/ripgrep.deb \
 && rm -rf /var/lib/apt/lists/* /tmp/ripgrep.deb
CMD ["sleep", "infinity"]