local physfs = require("physfs")
local thread = require("thread")

local modulePatcher = require("ModulePatcher")
local module = "sphere.persistence.CacheModel"

local function searchSongs()
	local paths = {
		{ "osu!", (os.getenv("USERPROFILE") or ""):gsub("%\\", "/") .. "/AppData/Local/osu!/Songs" },
		{ "osu!", "C:/osu!/Songs" },
		{ "osu!", "C:/Games/osu!/Songs" },
		{ "osu!", "C:/Program Files/osu!/Songs" },
		{ "osu!", "C:/Program Files (x86)/osu!/Songs" },
		{ "osu!", "D:/osu!/Songs" },
		{ "osu!", "D:/Games/osu!/Songs" },
		{ "Etterna", "C:/Etterna/Songs" },
		{ "Etterna", "C:/Games/Etterna/Songs" },
		{ "Etterna", "C:/Program Files/Etterna/Songs" },
		{ "Etterna", "C:/Program Files (x86)/Etterna/Songs" },
		{ "Etterna", "D:/Etterna/Songs" },
		{ "Etterna", "D:/Games/Etterna/Songs" },
		{ "Quaver", "C:/Program Files (x86)/Steam/steamapps/common/Quaver/Songs" },
		{ "Quaver", "C:/Steam/steamapps/common/Quaver/Songs" },
		{ "Quaver", "D:/Steam/steamapps/common/Quaver/Songs" },
	}

	local songs = {}

	for _, v in ipairs(paths) do
		local success, _ = physfs.mount(v[2], "found_songs", false)
		success = success and true or false

		if success then
			physfs.unmount(v[2])
			table.insert(songs, v)
		end
	end

	return songs
end

modulePatcher:insert(module, "load", function(self)
	thread.shared.cache = {
		state = 0,
		chartfiles_count = 0,
		chartfiles_current = 0,
	}
	self.shared = thread.shared.cache

	self.gdb:load()
	self.cacheStatus:update()

	self.locationManager:load()

	self.newSongs = {}

	if jit.os ~= "Windows" then
		return
	end

	local found_songs = searchSongs()
	local locations = self.locationManager.locations

	for _, songs in ipairs(found_songs) do
		local path = songs[2]
		local mounted = false

		for _, location in ipairs(locations) do
			if location.path == path then
				mounted = true
				break
			end
		end

		if not mounted then
			table.insert(self.newSongs, songs)
		end
	end
end)
