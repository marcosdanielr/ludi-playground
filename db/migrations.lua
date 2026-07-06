local users = require("schemas.users")

-- Each entry runs once, inside a transaction, tracked in _fredy_migrations.
-- Never edit an applied migration; add a new entry instead.
return function(db)
	return {
		{ name = "0001_create_users", up = users:create_sql(db:adapter()) },
	}
end
