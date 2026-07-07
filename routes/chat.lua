local chat_controller = require("controllers.chat")

local m = {}

function m.register(app)
	app:get("/rooms", chat_controller.list_rooms)
	app:ws("/chat/:id", chat_controller.join)
end

return m
