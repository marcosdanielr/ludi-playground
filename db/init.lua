local fredy = require("fredy")
local migrations = require("fredy.migrations")
local list = require("db.migrations")

local db = fredy.connect({
	adapter = "sqlite",
	path = os.getenv("DATABASE_PATH") or "app.db",
})

local ran = migrations.run(db, list(db))
if #ran > 0 then
	print("migrations applied: " .. table.concat(ran, ", "))
end

return db
