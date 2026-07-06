local app = require("app")

local port = 3001

app:listen(port, function()
	print(("Server running at http://localhost:%d"):format(port))
end)
