local class = require("class")

local Layout = require("sphere.views.GameplayView.Layout")

local flux = require("flux")
local just = require("just")
local gyatt = require("thetan.gyatt")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")

local PauseSubscreen = class()

PauseSubscreen.tween = nil
PauseSubscreen.alpha = 0

local failed = false

local function newImage(path)
	if not path then
		return nil
	end

	return love.graphics.newImage(path)
end

function PauseSubscreen:new(note_skin)
	if not note_skin then
		return
	end

	self.overlayImage = newImage(note_skin.overlay)
	self.overlayFailImage = newImage(note_skin.overlayFail)
	self.continueImage = newImage(note_skin.continue)
	self.retryImage = newImage(note_skin.retry)
	self.backImage = newImage(note_skin.back)
end

function PauseSubscreen:show()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, 0.22, { alpha = 1 }):ease("quadout")
end

function PauseSubscreen:hide()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, 0.22, { alpha = 0 }):ease("quadout")
end

---@param self table
local function bottomScreenMenu(self)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local w, h = Layout:move("footer")
	w = 279

	just.row(true)
	if imgui.TextOnlyButton("continue", "continue", w, h) then
		self.game.gameplayController:play()
	end
	if imgui.TextOnlyButton("retry", "retry", w, h) then
		self:retry()
	end
	if imgui.TextOnlyButton("quit", "quit", w, h) then
		self:quit()
	end

	just.row()

	w, h = Layout:move("header")
	love.graphics.translate(2 / 3 * w, 0)

	just.row(true)

	if imgui.TextOnlyButton("step_l", "left", h, h) then
		self.game.rhythmModel.timeEngine:stepTimePoint(true)
	end
	if imgui.TextOnlyButton("step_r", "right", h, h) then
		self.game.rhythmModel.timeEngine:stepTimePoint()
	end

	local ms = 1
	if love.keyboard.isDown("lshift") then
		ms = 10
	elseif love.keyboard.isDown("lctrl") then
		ms = 0.1
	end
	if imgui.TextOnlyButton("step_-", "-" .. ms .. "ms", h, h) then
		self.game.rhythmModel.timeEngine:stepTime(-ms / 1000)
	end
	if imgui.TextOnlyButton("step_+", "+" .. ms .. "ms", h, h) then
		self.game.rhythmModel.timeEngine:stepTime(ms / 1000)
	end

	just.row(true)

	imgui.Label("ctime", self.game.rhythmModel.timeEngine.currentTime, h)
	just.next(h / 2)
	imgui.Label("vtime", self.game.rhythmModel.timeEngine.currentVisualTime, h)
	just.next(h / 2)
	imgui.Label("cindex", self.game.rhythmModel.timeEngine.nearestTime.currentIndex, h)

	just.row()
end

function PauseSubscreen:overlay(view)
	local image = self.overlayImage

	if failed then
		image = self.overlayFailImage
	end

	if not image then
		return
	end

	local w, h = image:getDimensions()
	local ww, wh = love.graphics.getDimensions()

	local scale = ww / w
	w = w * scale
	h = h * scale

	love.graphics.draw(image, (ww / 2) - (w / 2), (wh / 2) - (h / 2), 0, scale, scale)
end

local y1 = 0.2222
local y2 = 0.4444
local y3 = 0.6666
local button_size = 0.22

local function button(image, _y)
	if not image then
		return
	end

	local w, h = image:getDimensions()
	local ww, wh = love.graphics.getDimensions()

	local x = (ww / 2) - (w / 2)
	local y = wh * _y

	love.graphics.origin()
	love.graphics.translate(x, y)
	local changed, active, hovered = just.button("button" .. _y, just.is_over(w, h))

	love.graphics.setColor({ 1, 1, 1, 1 })

	if hovered then
		love.graphics.setColor({ 0.7, 0.7, 1, 1 })
	end

	love.graphics.draw(image)

	return changed
end

function PauseSubscreen:buttons(view)
	local gameplayController = view.game.gameplayController

	if button(self.continueImage, y1) then
		gameplayController:changePlayState("play")
		self:hide()
	end
	if button(self.retryImage, y2) then
		gameplayController:changePlayState("retry")
		self:hide()
	end
	if button(self.backImage, y3) then
		view:quit()
	end
end

function PauseSubscreen:draw(view)
	love.graphics.origin()

	failed = view.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed()

	local previousCanvas = love.graphics.getCanvas()
	local layer = gyatt.getCanvas("pauseOverlay")
	love.graphics.setCanvas({ layer, stencil = true })
	love.graphics.clear()
	self:overlay(view)
	self:buttons(view)
	--bottomScreenMenu(view)
	love.graphics.setCanvas({ previousCanvas, stencil = true })

	love.graphics.origin()
	local a = self.alpha
	love.graphics.setColor(a, a, a, a)
	love.graphics.draw(layer)
end

return PauseSubscreen
