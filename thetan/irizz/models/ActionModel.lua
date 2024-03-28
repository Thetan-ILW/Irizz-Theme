local class = require("class")

local ActionModel = class()

local actions = {}

function ActionModel:new(configModel)
	self.configModel = configModel
end

function ActionModel:load()
	local configs = self.configModel.configs

	if configs.irizz.vimMotions then
		actions = configs.vim_keybinds
	else
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
	ralt = "ALT"
}

function ActionModel:formatGroup(groupName, formatTable)
	local t = {}
	local group = actions[groupName]

	for action, binding in pairs(group) do
		action = formatTable[action] or "IDIOT"
		if type(binding) == "string" then
			t[action] = binding
		elseif type(binding) == "table" then
			if binding.mod then
				t[action] = modFormat[binding.mod[1]] .. " + " .. table.concat(binding, " + ", 1)
			elseif binding.op then
				t[action] = binding.op
			end
		end
	end

	return t
end

return ActionModel
