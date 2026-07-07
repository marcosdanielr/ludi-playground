local ludi = require("ludi")
local users_routes = require("routes.users")
local chat_routes = require("routes.chat")

local app = ludi.new()

app:use(function(req, _, next)
	print(req.method .. " " .. req.path)
	next()
end)

-- Dev CORS: the Vite front (5173) fetches the API (3001) cross-origin.
app:use(function(_, res, next)
	res:header("Access-Control-Allow-Origin", "*")
	next()
end)

app:get("/ping", function(_, res)
	res:json({ pong = true })
end)

users_routes.register(app)
chat_routes.register(app)

return app
