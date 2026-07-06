local users = {}
local users_by_email = {}
local next_id = 1

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
	if users_by_email[email] then
		return nil, "email already exists"
	end

	local user = {
		id = next_id,
		name = data.name,
		email = email,
	}
	users[#users + 1] = user
	users_by_email[email] = user
	next_id = next_id + 1
	return user
end

function m.get_user_by_id(user_id)
	for _, user in ipairs(users) do
		if user.id == user_id then
			return user
		end
	end
	return nil
end

function m.search_users(query)
	local results = {}
	local q = query:lower()
	for _, user in ipairs(users) do
		if user.name:lower():find(q, 1, true) or user.email:lower():find(q, 1, true) then
			results[#results + 1] = user
		end
	end
	return results
end

return m
