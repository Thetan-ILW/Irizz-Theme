local modulePatcher = require("ModulePatcher")

local dirs = require("sphere.persistence.dirs")

modulePatcher:insert("sphere.persistence.Persistence", "load", function(_self)
	dirs.create()

	local configModel = _self.configModel
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
	configModel:read()

	_self.cacheModel:load()
end)
