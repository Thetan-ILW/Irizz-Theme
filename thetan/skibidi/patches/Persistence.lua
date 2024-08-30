local Persistence = require("sphere.persistence.Persistence")

local dirs = require("sphere.persistence.dirs")

function Persistence:load()
	dirs.create()

	local configModel = self.configModel
	configModel:open("settings", true)
	configModel:open("select", true)
	configModel:open("play", true)
	configModel:open("input", true)
	configModel:open("online", true)
	configModel:open("urls")
	configModel:open("judgements")
	configModel:open("filters")
	configModel:open("files")
	configModel:open("irizz", true)
	configModel:open("keybinds_v2", true)
	configModel:open("vim_keybinds_v2", true)
	configModel:open("osu_ui", true)
	configModel:read()

	self.cacheModel:load()
end
