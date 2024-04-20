local class = require("class")
local gyatt = require("thetan.gyatt")

local ActionModel = class()

local actions = {}

function ActionModel:new(configModel)
	self.configModel = configModel
end

function ActionModel:load()
	local configs = self.configModel.configs

	if configs.irizz.vimMotions then
		gyatt.inputMode = "vim"
		actions = configs.vim_keybinds
	else
		gyatt.inputMode = "keyboard"
		actions = configs.keybinds
	end
end

function ActionModel:getGroup(groupName)
	return actions[groupName]
end

local modFormat = {
	lctrl = "CTRL",
	rctrl = "CTRL",
	lshift = "SHIFT",
	rshift = "SHIFT",
	lalt = "ALT",
	ralt = "ALT",
}

local order = {
	global = {
		"quit",
		"increaseVolume",
		"decreaseVolume",
		"showChartInfo",
		"showKeybinds",
		"insertMode",
		"normalMode",
	},

	largeList = {
		"up",
		"down",
		"up10",
		"down10",
		"toStart",
		"toEnd",
	},

	smallList = {
		"up",
		"down",
	},

	songSelect = {
		"play",
		"autoPlay",
		"showMods",
		"showSkins",
		"showFilters",
		"showInputs",
		"showMultiplayer",
		"showKeybinds",
		"openEditor",
		"openResult",
		"decreaseTimeRate",
		"increaseTimeRate",
		"random",
		"undoRandom",
		"clearSearch",
		"moveScreenLeft",
		"moveScreenRight",
		"pauseMusic",
	},

	resultScreen = {
		"watchReplay",
		"retry",
		"submitScore",
	},
}

---@param groupName string
---@param localization string[]
function ActionModel:formatGroup(groupName, localization)
	local t = {}
	local group = actions[groupName]

	for _, actionName in ipairs(order[groupName]) do
		local action = localization[actionName] or "IDIOT"
		local binding = group[actionName]

		if type(binding) == "string" then
			table.insert(t, { action, binding })
		elseif type(binding) == "table" then
			if binding.mod then
				table.insert(t, { action, modFormat[binding.mod[1]] .. " + " .. table.concat(binding, " + ", 1) })
			elseif binding.op then
				table.insert(t, { action, binding.op })
			end
		end
	end

	return t
end

return ActionModel
