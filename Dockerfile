# Multi-stage:
#   dev   — run from source with hot reload (docker-compose target)
#   prod  — single binary from `ludi build`, minimal runtime
#
# Rust base because ludi and fredy are source rocks with a Rust core.

FROM rust:1-slim AS toolchain

RUN apt-get update && apt-get install -y --no-install-recommends \
    make gcc curl ca-certificates unzip zip pkg-config libsqlite3-dev git \
    && rm -rf /var/lib/apt/lists/*

# Lua 5.5 from source (no distro package for it in the base image)
RUN curl -fsSL https://www.lua.org/ftp/lua-5.5.0.tar.gz | tar xz \
    && make -C lua-5.5.0 linux install \
    && rm -rf lua-5.5.0

# LuaRocks 3.13+ (older versions don't recognize Lua 5.5 headers)
RUN curl -fsSL https://luarocks.org/releases/luarocks-3.13.0.tar.gz | tar xz \
    && cd luarocks-3.13.0 \
    && ./configure --with-lua=/usr/local \
    && make && make install \
    && cd .. && rm -rf luarocks-3.13.0

RUN luarocks install ludi && luarocks install fredy


FROM toolchain AS dev

WORKDIR /app

EXPOSE 3001

CMD ["lua", "server.lua"]


# Packs every *.lua plus a static Lua 5.5 into one executable. The entry
# is explicit: with both app.lua and server.lua present, `ludi build`
# refuses to guess.
FROM toolchain AS build

RUN curl -fsSL -o /usr/local/bin/ludi \
    https://github.com/Ludi-Framework/ludi/releases/latest/download/ludi-linux-x86_64 \
    && chmod +x /usr/local/bin/ludi

WORKDIR /src
COPY . .

RUN ludi build server.lua -o api


FROM debian:stable-slim AS prod

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --home /data app \
    && mkdir /data && chown app /data

COPY --from=build /src/api /usr/local/bin/api
# fredy_core is a native rock: it doesn't go into the bundle and resolves
# from the host LuaRocks tree, so the tree ships with the image.
COPY --from=toolchain /usr/local/share/lua/5.5 /usr/local/share/lua/5.5
COPY --from=toolchain /usr/local/lib/lua/5.5 /usr/local/lib/lua/5.5

ENV DATABASE_PATH=/data/app.db

USER app
WORKDIR /data

EXPOSE 3001

CMD ["api"]
