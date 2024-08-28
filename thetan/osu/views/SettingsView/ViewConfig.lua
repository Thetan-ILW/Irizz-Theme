local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")
local flux = require("flux")
local consts = require("thetan.osu.views.SettingsView.Consts")
local Layout = require("thetan.osu.views.OsuLayout")

---@class osu.SettingsViewConfig : IViewConfig
---@operator call: osu.SettingsViewConfig
---@field focus boolean
---@field hoverRectPosition number
---@field hoverRectTargetPosition number
---@field hoverRectTargetSize number
---@field hoverRectTween table?
local ViewConfig = IViewConfig + {}

local visibility = 0
---@type table<string, love.Image>
local img

local gfx = love.graphics

---@param assets osu.OsuAssets
function ViewConfig:new(assets)
	self.focus = false
	self.hoverRectPosition = 0
	self.hoverRectTargetPosition = 0
	self.hoverRectTargetSize = 0
	img = assets.images
end

function ViewConfig:tabs()
	local w, h = Layout:move("base")

	gfx.setColor(0, 0, 0, visibility)
	gfx.rectangle("fill", 0, 0, 64, h)
end

---@param view osu.SettingsView
function ViewConfig:panel(view)
	local w, h = Layout:move("base")
	local scale = gfx.getHeight() / 768

	gfx.setColor(0, 0, 0, 0.7 * visibility)
	gfx.translate(64, 0)
	gfx.rectangle("fill", 0, 0, 438 * visibility, h)

	self.focus = gyatt.isOver(438 * visibility, h)

	local prev_canvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas("settings_containers")

	gfx.setCanvas(canvas)

	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")

	if view.hoverPosition ~= self.hoverRectPosition then
		if self.hoverRectTween then
			self.hoverRectTween:stop()
		end
		self.hoverRectPosition = view.hoverPosition
		self.hoverRectTween =
			flux.to(self, 0.15, { hoverRectTargetPosition = view.hoverPosition, hoverRectTargetSize = view.hoverSize })
				:ease("quadout")
	end

	gfx.setColor(0, 0.4, 1, 0.6)
	gfx.translate(0, view.scrollPosition)

	for _, c in ipairs(view.containers) do
		gfx.rectangle("fill", 0, c.position, 438 + 60, 5)
	end

	view.topSpacing:draw()
	view.optionsLabel:update()
	view.optionsLabel:draw()
	view.gameBehaviorLabel:update()
	view.gameBehaviorLabel:draw()
	view.headerSpacing:draw()

	gfx.setColor(0, 0, 0, 0.6)
	gfx.rectangle("fill", 0, self.hoverRectTargetPosition, 438, self.hoverRectTargetSize)

	for _, c in ipairs(view.containers) do
		if -view.scrollPosition + 768 > c.position and -view.scrollPosition < c.position + c.height then
			c:draw()
		else
			gfx.translate(0, c.height + consts.groupSpacing)
		end
	end

	view.bottomSpacing:draw()

	gfx.setCanvas(prev_canvas)

	gfx.origin()
	gfx.setColor(1 * visibility, 1 * visibility, 1 * visibility, 1 * visibility)
	gfx.setScissor(64 * scale, 0, visibility * (438 * scale), h * scale)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(canvas)
	gfx.setBlendMode("alpha")
	gfx.setScissor()

	w, h = Layout:move("base")
	local ih = img.menuBackDefault:getHeight()
	gfx.translate(0, h - ih)
	gfx.draw(img.menuBackDefault)
end

---@param view osu.SettingsView
function ViewConfig:draw(view)
	Layout:draw()
	visibility = view.visibility

	self:tabs()
	self:panel(view)
end

return ViewConfig
