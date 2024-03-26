local class = require("class")
local gyatt = require("thetan.gyatt")

local InputMap = class()

function InputMap:call(group)
	local bindings = self[group]

	for k, v in pairs(bindings) do
		if gyatt.actionPressed(k) then
			v()
			return true
		end
	end

	return false
end

return InputMap
