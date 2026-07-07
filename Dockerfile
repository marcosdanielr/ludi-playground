# Dev image for the Lua API: Lua 5.5 + LuaRocks + ludi/fredy.
# Rust base because both rocks are source rocks with a Rust core (mlua).
FROM rust:1-slim

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

WORKDIR /app

EXPOSE 3001

CMD ["lua", "server.lua"]
