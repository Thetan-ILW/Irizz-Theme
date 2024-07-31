local class = require("class")

local flux = require("flux")
local just = require("just")
local gyatt = require("thetan.gyatt")

local Layout = require("thetan.irizz.views.GameplayView.OsuLayout")

local OsuPauseScreen = class()

OsuPauseScreen.tween = nil
OsuPauseScreen.alpha = 0

---@type table<string, love.Image>
local img
---@type table<string, audio.Source>
local snd

local failed = false

---@param assets osu.OsuPauseAssets
function OsuPauseScreen:new(assets)
	img = assets.images
	snd = assets.sounds
end

function OsuPauseScreen:show()
	if self.tween then
		self.tween:stop()
	end

	self.tween = flux.to(self, 0.22, { alpha = 1 }):ease("quadout")
	snd.loop:play()
end

function OsuPauseScreen:hide()
	if self.tween then
		self.tween:stop()
	end

	self.tween = flux.to(self, 0.22, { alpha = 0 }):ease("quadout")
	snd.loop:stop()
end

function OsuPauseScreen:unload()
	snd.loop:stop()
end

function OsuPauseScreen:overlay()
	local image = img.overlay

	if failed then
		image = img.overlayFail
	end

	Layout:move("overlay")

	local iw, ih = image:getDimensions()
	love.graphics.translate(-iw / 2, -ih / 2)
	love.graphics.draw(image)
end

---@param image love.Image
---@param position_name string
local function button(image, position_name)
	local iw, ih = image:getDimensions()
	local w, h = Layout:move(position_name)

	local x = -(iw / 2)
	local y = -(ih / 2)

	love.graphics.translate(x, y)
	local changed, active, hovered = just.button("button" .. position_name, just.is_over(iw, ih))

	love.graphics.setColor({ 1, 1, 1, 1 })

	if hovered then
		love.graphics.setColor({ 0.7, 0.7, 1, 1 })
	end

	love.graphics.draw(image)

	return changed
end

---@param view skibidi.ScreenView
function OsuPauseScreen:buttons(view)
	local gameplayController = view.game.gameplayController

	if not failed then
		if button(img.continue, "continue") then
			snd.continueClick:play()
			gameplayController:changePlayState("play")
			self:hide()
		end
	end

	if button(img.retry, "retry") then
		snd.retryClick:play()
		gameplayController:changePlayState("retry")
		self:hide()
	end

	if button(img.back, "back") then
		snd.backClick:play()
		view:quit()
	end
end

function OsuPauseScreen:updateAudio(view)
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local a = settings.audio
	local volume = a.volume.master * a.volume.music

	snd.loop:setVolume(volume * self.alpha)
end

---@param view irizz.GameplayView
---@param game_canvas love.Canvas
function OsuPauseScreen:draw(view, game_canvas)
	---@type boolean
	failed = view.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed()

	self:updateAudio(view)

	love.graphics.setColor({ 1, 1, 1, 1 })
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.origin()
	love.graphics.draw(game_canvas)
	love.graphics.setBlendMode("alpha")

	Layout:draw()

	local prev_canvas = love.graphics.getCanvas()
	local layer = gyatt.getCanvas("pauseOverlay")
	love.graphics.setCanvas({ layer, stencil = true })
	love.graphics.clear()
	self:overlay()
	self:buttons(view)
	love.graphics.setCanvas({ prev_canvas, stencil = true })

	love.graphics.origin()
	local a = self.alpha
	love.graphics.setColor(a, a, a, a)
	love.graphics.draw(layer)
end

return OsuPauseScreen
