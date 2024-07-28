local CacheModel = require("sphere.persistence.CacheModel")

local function exists(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then -- Permission denied, but it exists
			return true
		end
	end
	return ok, err
end

local function searchSongs()
	local paths = {
		{ "osu!", (os.getenv("USERPROFILE") or ""):gsub("%\\", "/") .. "/AppData/Local/osu!/Songs" },
		{ "osu!", "C:/osu!/Songs" },
		{ "osu!", "C:/Games/osu!/Songs" },
		{ "osu!", "C:/Program Files/osu!/Songs" },
		{ "osu!", "C:/Program Files (x86)/osu!/Songs" },
		{ "osu!", "D:/osu!/Songs" },
		{ "osu!", "D:/Games/osu!/Songs" },
		{ "osu!", "E:/osu!/Songs" },
		{ "osu!", "F:/osu!/Songs" },
		{ "Etterna", "C:/Etterna/Songs" },
		{ "Etterna", "C:/Games/Etterna/Songs" },
		{ "Etterna", "C:/Program Files/Etterna/Songs" },
		{ "Etterna", "C:/Program Files (x86)/Etterna/Songs" },
		{ "Etterna", "D:/Etterna/Songs" },
		{ "Etterna", "D:/Games/Etterna/Songs" },
		{ "Etterna", "E:/Etterna/Songs" },
		{ "Etterna", "F:/Etterna/Songs" },
		{ "Quaver", "C:/Program Files (x86)/Steam/steamapps/common/Quaver/Songs" },
		{ "Quaver", "C:/Steam/steamapps/common/Quaver/Songs" },
		{ "Quaver", "D:/Steam/steamapps/common/Quaver/Songs" },
	}

	local songs = {}

	for _, v in ipairs(paths) do
		if exists(v[2] .. "/") then
			table.insert(songs, v)
		end
	end

	return songs
end

local base_load = CacheModel.load

function CacheModel:load()
	base_load(self)

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
end
