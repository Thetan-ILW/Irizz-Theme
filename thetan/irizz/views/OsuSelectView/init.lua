local ScreenView = require("thetan.irizz.views.ScreenView")

local assets = require("thetan.irizz.assets")
local Theme = require("thetan.irizz.views.Theme")

local ViewConfig = require("thetan.irizz.views.OsuSelectView.ViewConfig")
local MainMenuView = require("thetan.irizz.views.MainMenuView")
local LayersView = require("thetan.irizz.views.LayersView")

local ChartPreviewView = require("sphere.views.SelectView.ChartPreviewView")

local InputMap = require("thetan.irizz.views.OsuSelectView.InputMap")

---@class irizz.OsuSelectView: irizz.ScreenView
---@operator call: irizz.OsuSelectView
local OsuSelectView = ScreenView + {}

local last_resize_time = math.huge

local playSound = nil
function OsuSelectView:load()
	self.game.selectController:load(self)

	self.chartPreviewView = ChartPreviewView(self.game)
	self.chartPreviewView:load()

	self.selectModel = self.game.selectModel

	playSound = Theme:getStartSound(self.game)

	self.inputMap = InputMap(self, self.actionModel)
	self.actionModel.enable()

	local configs = self.game.configModel.configs
	local irizz = configs.irizz

	local skin = assets.loadOsuSongSelect(("userdata/skins/%s/"):format(irizz.osuSongSelectSkin))

	self.viewConfig = ViewConfig(self.game, skin)
	self.mainMenuView = MainMenuView(self)
	self.layersView = LayersView(self.game, self.mainMenuView, "select", "preview")

	if irizz.showFreshInstallModal then
		local newSongs = self.game.cacheModel.newSongs
		local canAddSongs = #newSongs ~= 0

		if canAddSongs then
			self.gameView:openModal("thetan.irizz.views.modals.FreshInstallModal")
		end
	end
end

function OsuSelectView:beginUnload()
	self.game.selectController:beginUnload()
end

function OsuSelectView:unload()
	self.game.selectController:unload()
	self.chartPreviewView:unload()
end
---@param dt number
function OsuSelectView:update(dt)
	ScreenView.update(self, dt)

	self.viewConfig:setFocus(self.modal == nil)

	self.game.selectController:update()

	self.layersView:update()
	self.chartPreviewView:update(dt)

	if love.timer.getTime() > last_resize_time + 0.15 then
		self.viewConfig:resolutionUpdated()
		last_resize_time = math.huge
	end
end

function OsuSelectView:notechartChanged()
	self.viewConfig:updateInfo(self)
end

function OsuSelectView:play()
	if not self.game.selectModel:notechartExists() then
		return
	end

	if playSound ~= nil then
		playSound:play()
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		multiplayerModel:pushNotechart()
		self:changeScreen("multiplayerView")
		return
	end

	self:changeScreen("gameplayView")
end

function OsuSelectView:result()
	if self.game.selectModel:isPlayed() then
		self:changeScreen("resultView")
	end
end

function OsuSelectView:changeTimeRate(delta)
	if self.modalActive then
		return
	end

	local configs = self.game.configModel.configs
	local g = configs.settings.gameplay

	local timeRateModel = self.game.timeRateModel
	local range = timeRateModel.range[g.rate_type]

	local newRate = timeRateModel:get() + range[3] * delta

	if newRate ~= timeRateModel:get() then
		self.game.modifierSelectModel:change()
		timeRateModel:set(newRate)
		self.viewConfig:updateInfo(self)
	end
end

function OsuSelectView:updateSearch(text)
	local config = self.game.configModel.configs.select
	local selectModel = self.game.selectModel
	config.filterString = text
	selectModel:debouncePullNoteChartSet()
end

function OsuSelectView:receive(event)
	self.game.selectController:receive(event)
	self.chartPreviewView:receive(event)

	if event.name == "keypressed" then
		if self.inputMap:call("view") then
			return
		end

		if self.inputMap:call("selectModals") then
			return
		end

		if self.modal then
			return false
		end

		self.inputMap:call("select")
	end

	if event.name == "resize" then
		last_resize_time = love.timer.getTime()
	end
end

function OsuSelectView:quit()
	if self.mainMenuView:isActive() then
		self.mainMenuView:toggle()
	end
end

function OsuSelectView:draw()
	local function panelsStencil() end
	local function UI()
		self.viewConfig:draw(self)
	end

	self.layersView:draw(panelsStencil, UI)

	self.mainMenuView:draw("select", self)

	self:drawModal()
end

return OsuSelectView
