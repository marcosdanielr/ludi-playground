local users_controller = require("controllers.users")

local m = {}

function m.register(app)
	app:post("/users", users_controller.create)
	app:get("/users", users_controller.search)
	app:get("/users/:id", users_controller.get_by_id)
end

return m
