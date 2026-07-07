local json = require("ludi.json")

local m = {}

math.randomseed(os.time())

-- Gender-invariant adjectives, so any animal matches.
local ADJECTIVES = {
	"Veloz",
	"Feliz",
	"Genial",
	"Radical",
	"Sutil",
	"Vital",
	"Brutal",
	"Zen",
	"Astral",
	"Fenomenal",
	"Audaz",
	"Sagaz",
	"Tenaz",
	"Voraz",
	"Feroz",
	"Leal",
	"Sideral",
	"Imortal",
	"Ancestral",
	"Rebelde",
	"Errante",
	"Vibrante",
	"Brilhante",
	"Valente",
}

local ANIMALS = {
	"Capivara",
	"Tucano",
	"Jacaré",
	"Lobo",
	"Arara",
	"Tatu",
	"Onça",
	"Coruja",
	"Golfinho",
	"Raposa",
	"Gavião",
	"Tamanduá",
	"Lontra",
	"Jaguatirica",
	"Boto",
	"Sabiá",
	"Quati",
	"Anta",
	"Ariranha",
	"Cutia",
	"Seriema",
	"Falcão",
	"Polvo",
	"Pirarucu",
}

-- room id -> array of { conn = ludi conn, name = string }
local rooms = {}
local next_msg_id = 0

local function names_in(room)
	local names = {}
	for _, peer in ipairs(room) do
		table.insert(names, peer.name)
	end
	return names
end

local function random_name(room)
	local taken = {}
	for _, peer in ipairs(room) do
		taken[peer.name] = true
	end

	for _ = 1, 50 do
		local name = ANIMALS[math.random(#ANIMALS)] .. " " .. ADJECTIVES[math.random(#ADJECTIVES)]
		if not taken[name] then
			return name
		end
	end
	return "Anônimo " .. math.random(1000, 9999)
end

local function broadcast(room, payload, except)
	local encoded = json.encode(payload)
	for _, peer in ipairs(room) do
		if peer.conn ~= except then
			peer.conn:send(encoded)
		end
	end
end

-- GET /rooms: active rooms and how many people are in each, so the
-- front can list them. A room "exists" while someone is connected.
function m.list_rooms(_, res)
	local list = {}
	for id, room in pairs(rooms) do
		table.insert(list, { id = id, online = #room })
	end
	table.sort(list, function(a, b)
		return a.id < b.id
	end)
	res:json({ rooms = list, count = #list })
end

function m.join(conn, req)
	local room_id = req.params.id
	rooms[room_id] = rooms[room_id] or {}
	local room = rooms[room_id]

	local name = random_name(room)
	table.insert(room, { conn = conn, name = name })

	conn:send(json.encode({
		type = "welcome",
		room = room_id,
		name = name,
		online = #room,
		users = names_in(room),
	}))
	broadcast(room, { type = "join", name = name, online = #room, users = names_in(room) }, conn)

	conn:on("message", function(data)
		local ok, msg = pcall(json.decode, data)
		if not ok or type(msg) ~= "table" then
			return
		end

		if msg.type == "typing" then
			broadcast(room, { type = "typing", name = name }, conn)
		elseif msg.type == "message" and type(msg.text) == "string" and msg.text ~= "" then
			next_msg_id = next_msg_id + 1
			broadcast(room, {
				type = "message",
				id = next_msg_id,
				name = name,
				text = msg.text,
				at = os.time(),
			})
		end
	end)

	conn:on("close", function()
		for i, peer in ipairs(room) do
			if peer.conn == conn then
				table.remove(room, i)
				break
			end
		end

		if #room == 0 then
			rooms[room_id] = nil
		else
			broadcast(room, { type = "leave", name = name, online = #room, users = names_in(room) })
		end
	end)
end

return m
