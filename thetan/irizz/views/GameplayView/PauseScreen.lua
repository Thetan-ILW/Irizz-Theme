local class = require("class")

local flux = require("flux")
local gyatt = require("thetan.gyatt")

local Layout = require("sphere.views.GameplayView.Layout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textPauseSubscreen
local font

---@class irizz.PauseScreen
---@operator call: irizz.IrizzAssets
local PauseScreen = class()

---@type table?
PauseScreen.tween = nil
PauseScreen.alpha = 0

---@type table<string, love.Image[]>
local img
---@type love.Shader
local shader
---@type audio.Source
local ambient

---@param assets irizz.IrizzAssets
function PauseScreen:new(assets)
	local shaders = require("irizz.shaders")
	img = assets.images
	shader = shaders.waves
	ambient = assets.sounds.pauseAmbient

	font = Theme:getFonts("pauseSubscreen")
	ambient:stop()
end

function PauseScreen:show()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, 0.22, { alpha = 1 }):ease("quadout")
	ambient:play()
end

function PauseScreen:hide()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, 0.22, { alpha = 0 }):ease("quadout")
	ambient:stop()
end

function PauseScreen:unload()
	ambient:stop()
end

---@param game_canvas love.Canvas
---@param alpha number
function PauseScreen:shaderImage(game_canvas, alpha)
	local prev_shader = love.graphics.getShader()

	shader:send("time", love.timer.getTime())
	shader:send("screen", { love.graphics.getWidth(), love.graphics.getHeight() })
	shader:send("shaderColor", { 0.5, 0.7, 1.0, 1.0 })
	shader:send("alpha", alpha)
	love.graphics.setShader(shader)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(game_canvas)
	love.graphics.setBlendMode("alpha")
	love.graphics.setShader(prev_shader)
end

function PauseScreen:pauseText()
	local screen_w, screen_h = Layout:move("base")

	local text = Text.paused
	local paused_font = font.paused
	local width = paused_font:getWidth("P")
	local height = paused_font:getHeight()

	local total_h = #text * height

	local y = (screen_h / 2) - (total_h / 2)

	love.graphics.setFont(paused_font)
	love.graphics.setColor(Color.text)

	love.graphics.translate(40, y)

	for _, c in ipairs(text) do
		gyatt.text(c)
	end

	screen_w, screen_h = Layout:move("base")
	love.graphics.translate(screen_w - width - 40, y)
	for _, c in ipairs(text) do
		gyatt.text(c)
	end
end

local button_width = 500
local button_height = 80
local button_spacing = 30

---@param text string
---@param on_click function
local function button(text, on_click)
	local changed, active, hovered = gyatt.button(text .. "pause", gyatt.isOver(button_width, button_height))

	love.graphics.setColor(Color.uiFrames)

	if hovered then
		love.graphics.setColor(Color.accent)
	end

	local button_gradient = img.buttonGradient
	love.graphics.draw(button_gradient, 0, 0, 0, 1, 5)
	gyatt.frame(text, 0, 0, button_width, button_height, "center", "center")
	love.graphics.draw(button_gradient, 0, button_height, 0, 1, 5)

	love.graphics.setColor(Color.uiFrames)

	if changed then
		on_click()
	end
end

function PauseScreen:buttons(view)
	local w, h = Layout:move("base")
	love.graphics.setFont(font.buttons)
	love.graphics.setColor(Color.text)

	local total_h = (button_height * 3) + (button_spacing * 2)

	local x = (w / 2) - (button_width / 2)
	local y = (h / 2) - (total_h / 2)

	love.graphics.translate(x - 100, y)

	local gameplayController = view.game.gameplayController
	button(Text.resume, function()
		gameplayController:changePlayState("play")
		self:hide()
	end)

	love.graphics.translate(100, button_height + button_spacing)
	button(Text.retry, function()
		gameplayController:changePlayState("retry")
		self:hide()
	end)

	love.graphics.translate(100, button_height + button_spacing)
	button(Text.quit, function()
		view:quit()
	end)
end

function PauseScreen:draw(view, game_canvas)
	Layout:draw()
	love.graphics.origin()

	local a = self.alpha
	self:shaderImage(game_canvas, a)

	local prev_canvas = love.graphics.getCanvas()
	local layer = gyatt.getCanvas("pauseOverlay")
	love.graphics.setCanvas({ layer, stencil = true })
	love.graphics.clear()
	self:pauseText()
	self:buttons(view)
	love.graphics.setCanvas({ prev_canvas, stencil = true })

	love.graphics.setColor(a, a, a, a)
	love.graphics.origin()
	love.graphics.draw(layer)
end

return PauseScreen
