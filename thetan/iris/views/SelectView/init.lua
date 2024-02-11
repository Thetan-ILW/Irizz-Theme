local just = require("just")
local flux = require("flux")
local math_util = require("math_util")
local gfx_util = require("gfx_util")
local ScreenView = require("sphere.views.ScreenView")

local Layout = require("thetan.iris.views.SelectView.Layout")
local SelectViewConfig = require("thetan.iris.views.SelectView.SelectViewConfig")

local SettingsViewConfig = require("thetan.iris.views.SelectView.Settings")
local SongSelectViewConfig = require("thetan.iris.views.SelectView.SongSelect")
local CollectionViewConfig = require("thetan.iris.views.SelectView.Collections")

local BackgroundView = require("sphere.views.BackgroundView")

---@class iris.SelectView: sphere.ScreenView
---@operator call: iris.SelectView
local SelectView = ScreenView + {}

SelectView.modalActive = false
SelectView.screenX = 0
SelectView.screenXTarget = 0

local playSound = love.audio.newSource("iris/sounds/start.wav", "static")

function SelectView:load()
    self.game.selectController:load()
	self.selectViewConfig = SelectViewConfig(self.game)
	self.settingsViewConfig = SettingsViewConfig(self.game)
	self.songSelectViewConfig = SongSelectViewConfig(self.game)
	self.collectionsViewConfig = CollectionViewConfig(self.game)

	BackgroundView.game = self.game
end

function SelectView:beginUnload()
    self.game.selectController:beginUnload()
end

function SelectView:unload()
    self.game.selectController:unload()
	self.collectionsViewConfig = nil
end

---@param where number
---@param exact boolean
function SelectView:moveScreen(where, exact)
	if self.game.gameView.modal then
		return
	end
	
	self.screenXTarget = self.screenXTarget - where

	if exact then
		self.screenXTarget = -where
	end

	self.screenXTarget = math_util.clamp(-1, self.screenXTarget, 1)
	self.tween = flux.to(self, 0.32, {screenX = self.screenXTarget}):ease("quadout")
end

function SelectView:openModal(modalName)
	local modal = require(modalName)(self.game)
	self.game.gameView:setModal(modal)
end

---@param dt number
function SelectView:updateSettings(dt)

end

---@param dt number
function SelectView:updateSongSelect(dt)
	self.songSelectViewConfig:update(self)
	local ctrlDown = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

	if ctrlDown and just.keypressed("p") then
		self.game.previewModel:stop()
	end

	if (just.keypressed("f1")) then
		self:openModal("thetan.iris.views.modals.ModifierModal")
	end

	if ctrlDown and just.keypressed("s") then
		self:openModal("thetan.iris.views.modals.NoteSkinModal")
	end

	if ctrlDown and just.keypressed("i") then
		self:openModal("sphere.views.InputView")
	end

	if self.modalActive then
		return
	end

	if ctrlDown and just.keypressed("return") then
		self.game.rhythmModel:setAutoplay(true)
		self:play()
	end

	if just.keypressed("return") then
		local audioSettings = self.game.configModel.configs.settings.audio
		playSound:setVolume(audioSettings.volume.master * 0.3)
		playSound:play()
		self:play()
	end

	if ctrlDown and just.keypressed("e") then
		if not self.game.selectModel:notechartExists() then
			return
		end

		self:changeScreen("editorView")
	end
end

---@param dt number
function SelectView:updateCollections(dt)
	self.collectionsViewConfig:update(self)
end

function SelectView:switchToSongSelect()
	self.game.selectModel:debouncePullNoteChartSet()
end

---@param dt number
function SelectView:update(dt)
	local ctrlDown = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
	if ctrlDown and just.keypressed("r") then
		self:reloadViews()
	end

    self.game.selectController:update()

	if self.screenX == 0 then
		self:updateSongSelect(dt)
	elseif self.screenX == 1 then
		self:updateSettings(dt)
	elseif self.screenX == -1 then
		self:updateCollections(dt)
	end
end

---@param event table
function SelectView:receive(event)
    self.game.selectController:receive(event)
end

function SelectView:play()
	if not self.game.selectModel:notechartExists() then
		return
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		multiplayerModel:pushNotechart()
		self:changeScreen("multiplayerView")
		return
	end

	self:changeScreen("gameplayView")
end

function SelectView:result()
	if self.game.selectModel:isPlayed() then
		self:changeScreen("resultView")
	end
end

function SelectView:draw()
	Layout:draw()

	local w, h = Layout:move("background")
	local dim = self.game.configModel.configs.settings.graphics.dim.select
	BackgroundView:draw(w, h, dim, 0.01)

	local previousCanvas = love.graphics.getCanvas()
	local canvas = gfx_util.getCanvas("SelectView")

	love.graphics.setCanvas({canvas, stencil = true})
		love.graphics.clear()
		love.graphics.setBlendMode("alpha", "alphamultiply")
		self.selectViewConfig:draw(self)
		self.songSelectViewConfig:draw(self, self.screenX)
		self.collectionsViewConfig:draw(self, self.screenX + 1)
		self.settingsViewConfig:draw(self, self.screenX - 1)
	love.graphics.setCanvas(previousCanvas)

	local alpha = 1

	if self.modalActive then
		alpha = 1 - self.game.gameView.modal.alpha
	end

	love.graphics.origin()
	love.graphics.setColor(alpha, alpha, alpha, alpha)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(canvas)
	love.graphics.setBlendMode("alpha")
end

return SelectView