local class = require("class")

---@class osu.UiElement
---@operator call: osu.UiElement
---@field private onChange function
---@field private totalH number
---@field private margin number
---@field private hover boolean
local UiElement = class()

---@return number
function UiElement:getHeight()
	return self.totalH
end

---@return boolean
function UiElement:isMouseOver()
	return self.hover
end

---@param has_focus boolean
function UiElement:update(has_focus) end
function UiElement:draw()
	error("Silly mistake")
end

return UiElement
