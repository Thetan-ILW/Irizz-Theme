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

function PauseSubscreen:new(overlay_file_name, overlay_fail_file_name)
	if overlay_file_name then
		self.overlayImage = love.graphics.newImage(overlay_file_name)
	end

	if overlay_fail_file_name then
		self.overlayFailImage = love.graphics.newImage(overlay_fail_file_name)
	end
end

function PauseSubscreen:show()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, 0.3, { alpha = 1 }):ease("quadout")
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

	if view.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed() then
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

function PauseSubscreen:draw(view)
	love.graphics.origin()

	local previousCanvas = love.graphics.getCanvas()
	local layer = gyatt.getCanvas("pauseOverlay")
	love.graphics.setCanvas({ layer, stencil = true })
	love.graphics.clear()
	self:overlay(view)
	bottomScreenMenu(view)
	love.graphics.setCanvas({ previousCanvas, stencil = true })

	love.graphics.origin()
	local a = self.alpha
	love.graphics.setColor(a, a, a, a)
	love.graphics.draw(layer)
end

return PauseSubscreen
