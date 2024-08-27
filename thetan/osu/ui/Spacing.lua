local UiElement = require("thetan.osu.ui.UiElement")

---@class osu.ui.Spacing : osu.UiElement
---@operator call: osu.ui.Spacing
---@field private totalH number
local Spacing = UiElement + {}

function Spacing:new(size)
	self.totalH = size
end

function Spacing:draw()
	love.graphics.translate(0, self.totalH)
end

return Spacing
