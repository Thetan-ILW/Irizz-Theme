local just = require("just")
local flux = require("flux")
local math_util = require("math_util")
local ScreenView = require("sphere.views.ScreenView")

local Layout = require("thetan.iris.views.SelectView.Layout")
local SelectViewConfig = require("thetan.iris.views.SelectView.SelectViewConfig")

local SettingsViewConfig = require("thetan.iris.views.SelectView.Settings")
local SongSelectViewConfig = require("thetan.iris.views.SelectView.SongSelect")
local CollectionViewConfig = require("thetan.iris.views.SelectView.Collections")

---@class iris.SelectView: sphere.ScreenView
---@operator call: iris.SelectView
local SelectView = ScreenView + {}

SelectView.screenX = 0
SelectView.screenXTarget = 0

local playSound = love.audio.newSource("iris/sounds/start.wav", "static")

function SelectView:load()
    self.game.selectController:load()
	self.selectViewConfig = SelectViewConfig(self.game)
	self.settingsViewConfig = SettingsViewConfig(self.game)
	self.songSelectViewConfig = SongSelectViewConfig(self.game)
	self.collectionsViewConfig = CollectionViewConfig(self.game)

	self.modalActive = false
end

function SelectView:reloadViews()
	package.loaded["thetan.iris.views.Theme"]=nil
	package.loaded["thetan.iris.views.SelectView.Layout"]=nil
	package.loaded["thetan.iris.views.SelectView.SelectViewConfig"]=nil
	package.loaded["thetan.iris.views.SelectView.SettingsLayout"]=nil
	package.loaded["thetan.iris.views.SelectView.SettingsViewConfig"]=nil
	package.loaded["thetan.iris.views.SelectView.SongSelectLayout"]=nil
	package.loaded["thetan.iris.views.SelectView.SongSelectViewConfig"]=nil
	package.loaded["thetan.iris.views.SelectView.CollectionsLayout"]=nil
	package.loaded["thetan.iris.views.SelectView.CollectionsViewConfig"]=nil
	Layout = require("thetan.iris.views.SelectView.Layout")
	SelectViewConfig = require("thetan.iris.views.SelectView.SelectViewConfig")
	SettingsLayout = require("thetan.iris.views.SelectView.SettingsLayout")
	SettingsViewConfig = require("thetan.iris.views.SelectView.SettingsViewConfig")
	SongSelectLayout = require("thetan.iris.views.SelectView.SongSelectLayout")
	SongSelectViewConfig = require("thetan.iris.views.SelectView.SongSelectViewConfig")
	CollectionsLayout = require("thetan.iris.views.SelectView.CollectionsLayout")
	CollectionViewConfig = require("moddedgame.Iris-Theme.thetan.iris.views.SelectView.CollectionsView.init")
	self.selectViewConfig = SelectViewConfig(self.game)
	self.settingsViewConfig = SettingsViewConfig(self.game)
	self.songSelectViewConfig = SongSelectViewConfig(self.game)
	self.collectionsViewConfig = CollectionViewConfig(self.game)
end

function SelectView:beginUnload()
    self.game.selectController:beginUnload()
end

function SelectView:unload()
    self.game.selectController:unload()
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

function SelectView:openModal(modal)
	if self.game.gameView.modal then
		return
	end

	self.game.gameView:setModal(require(modal))
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
		self:openModal("sphere.views.ModifierView")
	end

	if ctrlDown and just.keypressed("s") then
		self:openModal("sphere.views.NoteSkinView")
	end

	if ctrlDown and just.keypressed("i") then
		self:openModal("sphere.views.InputView")
	end

	self.modalActive = self.game.gameView.modal ~= nil

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
	self.selectViewConfig:draw(self)
    self.songSelectViewConfig:draw(self, self.screenX)
	self.collectionsViewConfig:draw(self, self.screenX + 1)
	self.settingsViewConfig:draw(self, self.screenX - 1)
end

return SelectView