local users_service = require("services.users")

local m = {}

function m.create(req, res)
	local body = req:json()
	if not body then
		return res:status(400):json({ error = "invalid json" })
	end
	local user, err = users_service.add_user(body)
	if not user then
		local status = err == "email already exists" and 409 or 400
		return res:status(status):json({ error = err })
	end
	res:status(201):json(user)
end

function m.get_by_id(req, res)
	local id = tonumber(req.params.id)
	if not id then
		return res:status(400):json({ error = "invalid id" })
	end
	local user = users_service.get_user_by_id(id)
	if not user then
		return res:status(404):json({ error = "user not found" })
	end
	res:json(user)
end

function m.search(req, res)
	local query = req.query.q or ""

	res:json(users_service.search_users(query))
end

return m
