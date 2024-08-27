local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")
local Layout = require("thetan.osu.views.OsuLayout")

---@class osu.SettingsViewConfig : IViewConfig
---@operator call: osu.SettingsViewConfig
---@field focus boolean
local ViewConfig = IViewConfig + {}

local visibility = 0
---@type table<string, love.Image>
local img

local gfx = love.graphics

---@param assets osu.OsuAssets
function ViewConfig:new(assets)
	self.focus = false
	img = assets.images
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

	gfx.setColor(1, 1, 1, 1 * visibility)
	local ih = img.menuBackDefault:getHeight()
	gfx.translate(-64, h - ih)
	gfx.draw(img.menuBackDefault)
end

---@param view osu.SettingsView
function ViewConfig:draw(view)
	Layout:draw()
	visibility = view.visibility

	self:tabs()
	self:panel()
end

return ViewConfig
