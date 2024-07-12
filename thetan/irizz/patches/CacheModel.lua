local physfs = require("physfs")
local thread = require("thread")

local modulePatcher = require("ModulePatcher")
local module = "sphere.persistence.CacheModel"

local function searchSongs()
	local paths = {
		(os.getenv("USERPROFILE") or "") .. "/AppData/Local/osu!/Songs",
		"C:/osu!/Songs",
		"C:/Games/osu!/Songs",
		"C:/Program Files/osu!/Songs",
		"C:/Program Files (x86)/osu!/Songs",
		"D:/osu!/Songs",
		"D:/Games/osu!/Songs",
		"C:/Etterna/Songs",
		"C:/Games/Etterna/Songs",
		"C:/Program Files/Etterna/Songs",
		"C:/Program Files (x86)/Etterna/Songs",
		"D:/Etterna/Songs",
		"D:/Games/Etterna/Songs",
		"C:/Program Files (x86)/Steam/steamapps/common/Quaver/Songs",
		"C:/Steam/steamapps/common/Quaver/Songs",
		"D:/Steam/steamapps/common/Quaver/Songs",
		"/media/SSD/Charts/osu",
		"/media/SSD/Charts/BMS",
		"/media/SSD/Charts/SmCharts",
	}

	local songs = {}

	for _, v in ipairs(paths) do
		local success, _ = physfs.mount(v, "found_songs/", false)
		success = success and true or false

		if success then
			physfs.unmount("found_songs/")
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

	local found_songs = searchSongs()
	local locations = self.locationManager.locations

	self.newSongs = {}

	for _, path in ipairs(found_songs) do
		local mounted = false

		for _, location in ipairs(locations) do
			if location.path == path then
				mounted = true
				break
			end
		end

		if not mounted then
			table.insert(self.newSongs, path)
		end
	end
end)
