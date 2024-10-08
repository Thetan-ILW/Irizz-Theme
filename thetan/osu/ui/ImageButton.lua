local UiElement = require("thetan.osu.ui.UiElement")
local HoverState = require("thetan.osu.ui.HoverState")

local gyatt = require("thetan.gyatt")
local playSound = require("thetan.gyatt.play_sound")

---@class osu.ui.ImageButton : osu.UiElement
---@operator call: osu.ui.ImageButton
---@field alpha number
---@field private idleImage love.Image
---@field private hoverImage love.Image?
---@field private ay "top" | "bottom"
---@field private hoverX number
---@field private hoverY number
---@field private hoverWidth number
---@field private hoverHeight number
---@field private hoverSound audio.Source
---@field private clickSound audio.Source
---@field private onClick function
---@field private hoverState osu.ui.HoverState
---@field private animation number
local ImageButton = UiElement + {}

---@type love.Shader
local brighten_shader

---@param assets osu.OsuAssets
---@param params { idleImage: love.Image, hoverImage: love.Image?, ay?: "top" | "bottom", hoverArea: {w: number, h: number}, hoverSound: audio.Source?, clickSound: audio.Source?}
---@param on_click function
function ImageButton:new(assets, params, on_click)
	self.assets = assets
	self.idleImage = params.idleImage
	self.hoverImage = params.hoverImage
	self.ay = params.ay

	self.totalW, self.totalH = self.idleImage:getDimensions()

	if self.hoverImage then
		local w, h = self.hoverImage:getDimensions()
		self.totalW, self.totalH = math.max(w, self.totalW), math.max(h, self.totalH)
	end

	self.hoverWidth = params.hoverArea.w
	self.hoverHeight = params.hoverArea.h

	if self.ay == "bottom" then
		self.hoverX = 0
		self.hoverY = -self.hoverHeight
	end

	self.hoverSound = params.hoverSound or self.assets.sounds.hoverOverRect
	self.clickSound = params.clickSound or self.assets.sounds.clickShortConfirm
	self.onClick = on_click
	self.hoverState = HoverState("quadout", 0.15)
	self.animation = 0
	self.alpha = 1

	local shaders = require("irizz.shaders")
	brighten_shader = shaders.brighten
end

function ImageButton:update(has_focus)
	local hover ---@type boolean
	local just_hovered ---@type boolean
	hover, self.animation, just_hovered =
		self.hoverState:check(self.hoverWidth, self.hoverHeight, self.hoverX, self.hoverY, has_focus)

	if just_hovered then
		playSound(self.hoverSound)
	end

	if hover and gyatt.mousePressed(1) then
		self.onClick()
		self.clickSound:stop()
		self.clickSound:play()
	end
end

local gfx = love.graphics

function ImageButton:draw()
	gfx.setColor(1, 1, 1, self.alpha)

	local y1 = 0
	local y2 = 0

	if self.ay == "bottom" then
		y1 = -self.idleImage:getHeight()

		if self.hoverImage then
			y2 = -self.hoverImage:getHeight()
		end
	end

	if self.hoverImage then
		gfx.draw(self.idleImage, 0, y1)
		gfx.setColor(1, 1, 1, self.animation * self.alpha)
		gfx.draw(self.hoverImage, 0, y2)
		return
	end

	local prev_shader = gfx.getShader()
	gfx.setShader(brighten_shader)
	brighten_shader:send("amount", self.alpha * self.animation * 0.3)
	gfx.draw(self.idleImage, 0, y1)
	gfx.setShader(prev_shader)
end

return ImageButton
