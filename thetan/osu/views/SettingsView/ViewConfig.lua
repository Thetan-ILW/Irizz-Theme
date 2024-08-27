local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")
local Layout = require("thetan.osu.views.OsuLayout")

---@class osu.SettingsViewConfig : IViewConfig
---@operator call: osu.SettingsViewConfig
---@field focus boolean
local ViewConfig = IViewConfig + {}

local visibility = 0

local gfx = love.graphics

function ViewConfig:new()
	self.focus = false
end

function ViewConfig:tabs()
	local w, h = Layout:move("base")

	gfx.setColor(0, 0, 0, visibility)
	gfx.rectangle("fill", 0, 0, 64, h)
end

function ViewConfig:panel()
	local w, h = Layout:move("base")

	gfx.setColor(0, 0, 0, 0.7 * visibility)
	gfx.translate(64, 0)
	gfx.rectangle("fill", 0, 0, 438 * visibility, h)

	self.focus = gyatt.isOver(438 * visibility, h)
end

---@param view osu.SettingsView
function ViewConfig:draw(view)
	Layout:draw()
	visibility = view.visibility

	self:tabs()
	self:panel()
end

return ViewConfig
