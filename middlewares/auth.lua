-- Fake session store while there is no login flow.
local tokens = {
	["ludi-dev-token"] = { id = 0, name = "Admin" },
}

local m = {}

function m.required(req, res, next)
	local header = req.headers["authorization"] or req.headers["Authorization"]
	local token = header and header:match("^Bearer%s+(.+)$")
	local user = token and tokens[token]

	if not user then
		return res:status(401):json({ error = "unauthorized" })
	end

	req.user = user
	next()
end

return m
