local db = require("db")
local users = require("schemas.users")

local m = {}

function m.add_user(data)
	if type(data) ~= "table" then
		return nil, "invalid payload"
	end
	if type(data.name) ~= "string" or data.name == "" then
		return nil, "name is required"
	end
	if type(data.email) ~= "string" or not data.email:find("^[^@%s]+@[^@%s]+%.[^@%s]+$") then
		return nil, "invalid email"
	end

	local email = data.email:lower()
	if db:table(users):where({ email = email }):first() then
		return nil, "email already exists"
	end

	return db:table(users):insert({ name = data.name, email = email })
end

function m.get_user_by_id(user_id)
	return db:table(users):where({ id = user_id }):first()
end

function m.search_users(query)
	local builder = db:table(users)
	if query ~= "" then
		local like = "%" .. query:lower() .. "%"
		builder = builder:where_raw("(lower(name) like ? or lower(email) like ?)", { like, like })
	end
	return builder:order_by("id"):all()
end

return m
