local class = require("class")

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
	local success, image = pcall(love.graphics.newImage, path)
	return success and image or nil
end

local function newAudio(path, type)
	local success, audio = pcall(love.audio.newSource, path, type)
	return success and audio or nil
end

local function play(source)
	if source then
		source:stop()
		source:play()
	end
end

local function setVolume(source, volume)
	if source then
		source:setVolume(volume)
	end
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

	self.loopAudio = newAudio(note_skin.loop, "stream")
	self.continueClick = newAudio(note_skin.continueClick, "static")
	self.retryClick = newAudio(note_skin.retryClick, "static")
	self.backClick = newAudio(note_skin.backClick, "static")
end

function PauseSubscreen:show()
	if self.tween then
		self.tween:stop()
	end
	self.tween = flux.to(self, 0.22, { alpha = 1 }):ease("quadout")

	play(self.loopAudio)
end

function PauseSubscreen:hide()
	if self.tween then
		self.tween:stop()
	end

	self.tween = flux.to(self, 0.22, { alpha = 0 }):ease("quadout")
end

function PauseSubscreen:unload()
	if self.loopAudio then
		self.loopAudio:stop()
		self.loopAudio:release()
	end
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

	local scale = math.max(ww / w, wh / h)

	w = w * scale
	h = h * scale

	love.graphics.draw(image, (ww / 2) - (w / 2), (wh / 2) - (h / 2), 0, scale, scale)
end

local function button(image, _y)
	if not image then
		return
	end

	local iw, ih = image:getDimensions()
	local w, h = love.graphics.getDimensions()

	local x = (w / 2) - (iw / 2)
	local y = h * _y

	love.graphics.origin()
	love.graphics.translate(x, y)
	local changed, active, hovered = just.button("button" .. _y, just.is_over(iw, ih))

	love.graphics.setColor({ 1, 1, 1, 1 })

	if hovered then
		love.graphics.setColor({ 0.7, 0.7, 1, 1 })
	end

	love.graphics.draw(image)

	return changed
end

function PauseSubscreen:buttons(view)
	local gameplayController = view.game.gameplayController

	if not failed then
		if button(self.continueImage, 0.2222) then
			play(self.continueClick)
			gameplayController:changePlayState("play")
			self:hide()
		end
	end

	if button(self.retryImage, 0.4444) then
		play(self.retryClick)
		gameplayController:changePlayState("retry")
		self:hide()
	end

	if button(self.backImage, 0.6666) then
		play(self.backClick)
		view:quit()
	end
end

function PauseSubscreen:updateAudio(view)
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local a = settings.audio
	local volume = a.volume.master * a.volume.music

	setVolume(self.loopAudio, volume * self.alpha)
	setVolume(self.continueClick, volume)
	setVolume(self.retryClick, volume)
	setVolume(self.backClick, volume)
end

function PauseSubscreen:draw(view)
	love.graphics.origin()

	failed = view.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed()

	self:updateAudio(view)

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
