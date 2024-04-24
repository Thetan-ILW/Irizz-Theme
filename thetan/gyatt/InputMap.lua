local class = require("class")

---@class gyatt.InputMap
---@operator call: gyatt.InputMap
local InputMap = class()

---@type irizz.ActionModel
InputMap.actionModel = nil

---@param view sphere.ScreenView
function InputMap:createBindings(view) end

---@param view sphere.ScreenView
---@param actionModel irizz.ActionModel
function InputMap:new(view, actionModel)
	self:createBindings(view)
	self.actionModel = actionModel
end

---@param group string
---@return boolean
function InputMap:call(group)
	local bindings = self[group]

	local f = bindings[self.actionModel.getAction()]

	if f then
		f()
		self.actionModel.resetInputs()
		return true
	end

	return false
end

return InputMap
