local UiElement = require("thetan.osu.ui.UiElement")
local HoverState = require("thetan.osu.ui.HoverState")

local gyatt = require("thetan.gyatt")

---@class osu.ui.ImageButton : osu.UiElement
---@operator call: osu.ui.ImageButton
---@field alpha number
---@field private idleImage love.Image
---@field private hoverImage love.Image?
---@field private hoverWidth number
---@field private hoverHeight number
---@field private onClick function
---@field private hoverState osu.ui.HoverState
---@field private animation number
local ImageButton = UiElement + {}

---@type love.Shader
local brighten_shader

---@param params { idleImage: love.Image, hoverImage: love.Image?, hoverWidth: number, hoverHeight: number}
---@param on_click function
function ImageButton:new(params, on_click)
	self.idleImage = params.idleImage
	self.hoverImage = params.hoverImage
	self.totalW, self.totalH = self.idleImage:getDimensions()
	self.hoverWidth = params.hoverWidth
	self.hoverHeight = params.hoverHeight
	self.onClick = on_click
	self.hoverState = HoverState("quadout", 0.15)
	self.animation = 0
	self.alpha = 1

	local shaders = require("irizz.shaders")
	brighten_shader = shaders.brighten
end

function ImageButton:update(has_focus)
	local hover
	hover, self.animation = self.hoverState:check(self.hoverWidth, self.hoverHeight, 0, 0, has_focus)

	if hover and gyatt.mousePressed(1) then
		self.onClick()
	end
end

local gfx = love.graphics

function ImageButton:draw()
	gfx.setColor(1, 1, 1, self.alpha)

	if self.hoverImage then
		gfx.draw(self.idleImage)
		gfx.setColor(1, 1, 1, self.animation * self.alpha)
		gfx.draw(self.hoverImage)
		return
	end

	local prev_shader = gfx.getShader()
	gfx.setShader(brighten_shader)
	brighten_shader:send("amount", self.alpha * self.animation * 0.3)
	gfx.draw(self.idleImage)
	gfx.setShader(prev_shader)
end

return ImageButton
