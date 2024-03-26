local class = require("class")
local gyatt = require("thetan.gyatt")

---@class thetan.gyatt.InputMap
---@operator call: thetan.gyatt.InputMap
local InputMap = class()

---@param view sphere.ScreenView
---@param actions table
function InputMap:createBindings(view, actions)	end

---@param view sphere.ScreenView
---@param actions table
function InputMap:new(view, actions)
	self:createBindings(view, actions)
end

---@param group string
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
