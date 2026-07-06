local schema = require("fredy.schema")

return schema.table("users", {
	id = schema.integer({ primary = true }),
	name = schema.text({ required = true }),
	email = schema.text({ required = true, unique = true }),
})
