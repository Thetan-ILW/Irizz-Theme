local just = require("just")
local Spoiler = require("thetan.irizz.imgui.Spoiler")
local TextOnlyButton = require("thetan.irizz.imgui.TextOnlyButton")

local Theme = require("thetan.irizz.views.Theme")
local cfg = Theme.imgui

return function(id, w, h, list, preview, to_string)
	local _i, _name
	if Spoiler(id, w, h, preview) then
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, w, h * cfg.size * #list)

		for i, name in ipairs(list) do
			name = to_string and to_string(name) or name
			if TextOnlyButton("spoiler" .. i, name, w, cfg.size, "center") then
				_i, _name = i, name
				just.focus()
			end
		end
		Spoiler(nil, w, h)
	end
	return _i, _name
end
