FROM erlang:23.3

ENV ELIXIR_VERSION="v1.13.1"
ENV RUST_VERSION="1.57.0"
ENV LANG="C.UTF-8"

RUN apt-get update && \
  apt-get install \
  ca-certificates \
  curl \
  gcc \
  libc6-dev \
  -qqy \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Install Elixir
RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
  && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
  && mkdir -p /usr/local/src/elixir \
  && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
  && rm elixir-src.tar.gz \
  && cd /usr/local/src/elixir \
  && make install clean

# Install Rust
RUN RUST_ARCHIVE="rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz" && \
  RUST_DOWNLOAD_URL="https://static.rust-lang.org/dist/$RUST_ARCHIVE" && \
  mkdir -p /rust \
  && cd /rust \
  && curl -fsOSL $RUST_DOWNLOAD_URL \
  && tar -C /rust -xzf $RUST_ARCHIVE --strip-components=1 \
  && rm $RUST_ARCHIVE \
  && ./install.sh

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

CMD mix local.hex --force && mix deps.get && mix phx.server