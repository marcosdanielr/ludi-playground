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
services/users.lua   -- business rules, in-memory store
```

### Endpoints

| Method | Path         | Description                                  |
|--------|--------------|----------------------------------------------|
| GET    | `/ping`      | Health check                                 |
| POST   | `/users`     | Create user (`name`, `email`)                |
| GET    | `/users`     | List users, optional `?q=` search by name/email |
| GET    | `/users/:id` | Get user by id                               |

Validation: required name, email format check, case-insensitive unique email. Errors map to proper status codes (`400`, `404`, `409`).

## Requirements

- Lua 5.4
- [LuaRocks](https://luarocks.org)
- ludi installed locally (not yet published to LuaRocks):

```sh
git clone https://github.com/Ludi-Framework/ludi
cd ludi
luarocks --lua-version 5.4 make ludi-dev-1.rockspec
```

Make sure the LuaRocks paths are in your shell:

```sh
eval "$(luarocks --lua-version 5.4 path)"
```

## Running

```sh
lua5.4 server.lua
```

Server listens on `http://localhost:3001`.

```sh
curl -X POST localhost:3001/users -d '{"name": "Ana", "email": "ana@example.com"}'
curl 'localhost:3001/users?q=ana'
```
