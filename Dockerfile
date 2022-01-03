ARG MIX_ENV="prod"

FROM erlang:23.3 AS build

ENV ELIXIR_VERSION="v1.13.1"
ENV RUST_VERSION="1.57.0"
ENV NODE_VERSION="14.x"
ENV LANG="C.UTF-8"

RUN apt-get update && \
  apt-get install \
  ca-certificates \
  curl \
  gcc \
  libc6-dev \
  inotify-tools \
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

ENV NODE_DOWNLOAD_URL="https://deb.nodesource.com/setup_$NODE_VERSION"
RUN curl -sL $NODE_DOWNLOAD_URL | bash - \
  && apt-get install -y nodejs

RUN npm install --unsafe-perm -g elm

# Bust cache for app
ARG bsb_version="0.1.2"

WORKDIR /app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install && node build.js
RUN mix phx.digest

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
# at this point we should copy the rel directory but
# we are not using it so we can omit it
# COPY rel rel
RUN mix release

# prepare release image
FROM erlang:23.3 AS app

# install runtime dependencies
RUN apt-get update && \
  apt-get install \
  openssl postgresql-client \
  inotify-tools \
  -qqy \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 4000
ENV MIX_ENV=prod

# prepare app directory
RUN mkdir /app
WORKDIR /app

# copy release to app container
COPY --from=build /app/_build/prod/rel/bsb2022 .
COPY entrypoint.sh .
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
CMD ["bash", "/app/entrypoint.sh"]