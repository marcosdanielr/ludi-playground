local ludi = require("ludi")
local users_routes = require("routes.users")

local app = ludi.new()

app:use(function(req, _, next)
	print(req.method .. " " .. req.path)
	next()
end)

app:get("/ping", function(_, res)
	res:json({ pong = true })
end)

users_routes.register(app)

return app
