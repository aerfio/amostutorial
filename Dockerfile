# syntax = docker/dockerfile:1

FROM ubuntu:22.04

# Install curl
RUN set -eux; \
		apt update; \
		apt install -y curl gcc pkg-config libssl-dev;

# Install rustup
RUN --mount=type=cache,target=/root/.rustup \
    set -eux; \
    curl --location --fail \
      "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" \
      --output rustup-init; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain stable; \
    rm rustup-init;

# Add rustup to path, check that it works
ENV PATH=${PATH}:/root/.cargo/bin
RUN set -eux; \
		rustup --version;

# Copy sources and build them
WORKDIR /app
COPY src src
COPY Cargo.toml Cargo.lock ./
RUN --mount=type=cache,target=/root/.rustup \
    --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/.cargo/git \
		--mount=type=cache,target=/app/target \
		set -eux; \
		cargo build --release; \
		cp target/release/amostutorial .

CMD ["/app/amostutorial"]
