# ludi-playground

Test applications for the [ludi](https://github.com/Ludi-Framework/ludi) web framework — a minimal Express-inspired HTTP framework for Lua with a Rust core.

This repo exercises the framework end-to-end with real apps while ludi is under development.

## Users API

A small REST API with a layered architecture:

```
app.lua              -- app setup, middleware, route registration
server.lua           -- entry point
routes/users.lua     -- endpoint → controller mapping
controllers/users.lua -- request handling, error-to-status mapping
services/users.lua   -- business rules
middlewares/auth.lua -- bearer-token auth (fake session store for now)
schemas/users.lua    -- fredy table schema
db/init.lua          -- database connection + migration runner
db/migrations.lua    -- migration list
```

Persistence uses [fredy](https://github.com/Ludi-Framework/fredy) (SQLite adapter). Migrations run automatically on startup.

### Endpoints

| Method | Path         | Description                                  |
|--------|--------------|----------------------------------------------|
| GET    | `/ping`      | Health check                                 |
| POST   | `/users`     | Create user (`name`, `email`) — requires auth |
| GET    | `/users`     | List users, optional `?q=` search by name/email |
| GET    | `/users/:id` | Get user by id                               |

`POST /users` expects `Authorization: Bearer ludi-dev-token` (hardcoded dev token until there is a login flow) and returns `401` without it.

Validation: required name, email format check, case-insensitive unique email. Errors map to proper status codes (`400`, `401`, `404`, `409`).

## Chat (WebSockets)

Exercises ludi's WebSocket support (`app:ws`) with a room-based chat:

```
routes/chat.lua      -- GET /rooms + WS /chat/:id
controllers/chat.lua -- rooms, random names, broadcast, typing events
```

| Method | Path        | Description                                   |
|--------|-------------|-----------------------------------------------|
| GET    | `/rooms`    | Active rooms and how many people are in each  |
| WS     | `/chat/:id` | Join room `:id` (created on first connection) |

Every connection gets a server-assigned random name ("Capivara Zen",
"Tucano Feliz"). Messages are JSON, client → server:

```json
{ "type": "message", "text": "olá" }
{ "type": "typing" }
```

Server → client: `welcome` (your name, who's online), `join` / `leave`,
`message` (broadcast, with incremental `id`) and `typing` (relayed to
everyone else; the front expires it after 2.5s).

## Chat front (web/)

React + TypeScript + Tailwind (Vite, pnpm) client for the chat: pick or
create a room, see who's typing, last 20 messages kept in memory.

```sh
cd web
pnpm install
pnpm dev
```

The API address is derived from the page host, so opening
`http://<lan-ip>:5173` from a phone on the same network just works.

## Docker (dev)

Runs API + front with one command, no local Lua or Node needed:

```sh
docker compose up
```

- API on `http://localhost:3001`, built from the `Dockerfile` (Lua 5.5 +
  LuaRocks 3.13 + ludi/fredy) and started with `LUDI_WATCH=1` — the source
  is bind-mounted, so editing `*.lua` hot-reloads inside the container.
- Front on `http://localhost:5173`, Vite dev server with HMR;
  `node_modules` lives in a named volume so host and container installs
  don't clash.

## Docker (prod)

The `prod` target packs the whole app into a single binary with
`ludi build` and ships it on a slim Debian (~90MB, no Lua, no LuaRocks —
only fredy's native module rides along in the LuaRocks tree):

```sh
docker build --target prod -t api .
docker run -p 3001:3001 -v api-data:/data api
```

The SQLite database lives in `/data` (a volume), configurable with
`DATABASE_PATH`.

## Requirements

- Lua 5.5 (recommended)
- [LuaRocks](https://luarocks.org) 3.13+ (older versions don't recognize
  Lua 5.5 headers)

```sh
luarocks install ludi
luarocks install fredy
```

Or, to develop against the framework checkouts:

```sh
git clone https://github.com/Ludi-Framework/ludi
cd ludi
luarocks make ludi-dev-1.rockspec

git clone https://github.com/Ludi-Framework/fredy
cd fredy
luarocks make fredy-dev-1.rockspec
```

Make sure the LuaRocks paths are in your shell:

```sh
eval "$(luarocks path)"
```

## Running

```sh
lua server.lua
```

Server listens on `http://localhost:3001`. The SQLite database is created at `app.db` (override with `DATABASE_PATH`).

```sh
curl -X POST localhost:3001/users \
  -H 'Authorization: Bearer ludi-dev-token' \
  -d '{"name": "Ana", "email": "ana@example.com"}'
curl 'localhost:3001/users?q=ana'
```
