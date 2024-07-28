local flux = require("flux")
local math_util = require("math_util")
local gyatt = require("thetan.gyatt")
local ScreenView = require("thetan.skibidi.views.ScreenView")

local Theme = require("thetan.irizz.views.Theme")
local HeaderView = require("thetan.irizz.views.HeaderView")

local get_assets = require("thetan.irizz.assets_loader")

local LayersView = require("thetan.irizz.views.LayersView")
local SettingsViewConfig = require("thetan.irizz.views.SelectView.Settings")
local SongSelectViewConfig = require("thetan.irizz.views.SelectView.SongSelect")
local CollectionViewConfig = require("thetan.irizz.views.SelectView.Collections")
local MainMenuView = require("thetan.irizz.views.MainMenuView")

local ChartPreviewView = require("sphere.views.SelectView.ChartPreviewView")

local InputMap = require("thetan.irizz.views.SelectView.InputMap")

---@class irizz.SelectView: skibidi.ScreenView
---@operator call: irizz.SelectView
---@field assets irizz.IrizzAssets
local SelectView = ScreenView + {}

SelectView.modalActive = false
SelectView.screenX = 0
SelectView.screenXTarget = 0

SelectView.chartFilterLine = ""
SelectView.scoreFilterLine = ""

local songSelectOffset = 0

---@type audio.Source
local start_sound

local window_height = 1080

function SelectView:load()
	self.game.selectController:load(self)

	self.chartPreviewView = ChartPreviewView(self.game)
	self.chartPreviewView:load()

	self.selectModel = self.game.selectModel

	local configs = self.game.configModel.configs
	local irizz = configs.irizz

	self.assets = get_assets(self.game)

	self.headerView = HeaderView(self.game, self.assets, "select")
	self.settingsViewConfig = SettingsViewConfig(self.game, self.assets)
	self.songSelectViewConfig = SongSelectViewConfig(self.game, self.assets)
	self.collectionsViewConfig = CollectionViewConfig(self.game, self.assets)

	self.inputMap = InputMap(self, self.actionModel)

	self:updateFilterLines()
	self.mainMenuView = MainMenuView(self)
	self.layersView = LayersView(self.game, self.assets, self.mainMenuView, "select", "preview")

	if irizz.showFreshInstallModal then
		local newSongs = self.game.cacheModel.newSongs
		local canAddSongs = #newSongs ~= 0

		if canAddSongs then
			self:openModal("thetan.irizz.views.modals.FreshInstallModal")
		end
	end

	self:resolutionUpdated()
end

function SelectView:beginUnload()
	self.game.selectController:beginUnload()
end

function SelectView:unload()
	self.game.selectController:unload()
	self.collectionsViewConfig = nil
	self.chartPreviewView:unload()
end

---@param where number
---@param exact? boolean
function SelectView:moveScreen(where, exact)
	if self.modalActive then
		return
	end

	self.screenXTarget = self.screenXTarget - where

	if exact then
		self.screenXTarget = -where
	end

	self.screenXTarget = math_util.clamp(-1, self.screenXTarget, 1)
	self.tween = flux.to(self, 0.32, { screenX = self.screenXTarget }):ease("quadout")

	if self.screenXTarget == 0 then
		self:switchToSongSelect()
		self.collectionsViewConfig:setMode(self, "Collections")
	elseif self.screenXTarget == 1 then
		self:switchToSettings()
	end

	self.assets.sounds.songSelectScreenChanged:play()
end

---@param dt number
function SelectView:updateSettings(dt) end

function SelectView:switchToSongSelect()
	self.game.selectModel:noDebouncePullNoteChartSet()
end

function SelectView:switchToSettings()
	self.settingsViewConfig:focused()
end

---@param dt number
function SelectView:update(dt)
	ScreenView.update(self, dt)

	self.assets:updateVolume(self.game.configModel)

	self.game.selectController:update()

	if self.screenX == 1 then
		self:updateSettings(dt)
	end

	self.layersView:update()
	self.chartPreviewView:update(dt)

	local configs = self.game.configModel.configs
	local irizz = configs.irizz
	local ss_offset = irizz.songSelectOffset

	songSelectOffset = ss_offset
end

function SelectView:notechartChanged()
	self.songSelectViewConfig:updateInfo(self)
end

function SelectView:play()
	if not self:canUpdate() then
		return
	end

	if not self.game.selectModel:notechartExists() then
		return
	end

	local configs = self.game.configModel.configs
	local irizz = configs.irizz

	start_sound = self.assets.startSounds[irizz.startSound] or require("audio.Source") -- Remove later in several months
	start_sound:play()

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

function SelectView:updateFilterLines()
	local filters = self.game.configModel.configs.filters.notechart
	local filterModel = self.game.selectModel.filterModel
	local select = self.game.configModel.configs.select
	local output = {}

	for _, group in ipairs(filters) do
		local activeValues = {}

		for _, filter in ipairs(group) do
			if filterModel:isActive(group.name, filter.name) then
				table.insert(activeValues, filter.name)
			end
		end

		if #activeValues ~= 0 then
			local groupValues = Theme.formatFilter(group.name) .. ": " .. table.concat(activeValues, ", ")
			table.insert(output, groupValues)
		end
	end

	self.chartFilterLine = table.concat(output, "   ")

	local mode = select.scoreFilterName
	local source = select.scoreSourceName

	mode = mode == "No filter" and "" or mode
	source = source == "local" and "" or "Online"

	self.scoreFilterLine = ("%s   %s"):format(source, mode)
end

function SelectView:isInOsuDirect()
	local inOsuDirect = self.collectionsViewConfig:getModeName() == "osu!direct"
	return inOsuDirect and self.screenX == -1
end

function SelectView:changeTimeRate(delta)
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
		self.songSelectViewConfig:updateInfo(self)
	end
end

function SelectView:updateSearch(text)
	local config = self.game.configModel.configs.select
	local selectModel = self.game.selectModel
	config.filterString = text
	selectModel:debouncePullNoteChartSet()
end

function SelectView:songSelectInputs()
	if self.inputMap:call("selectModals") then
		return
	end

	if self.modalActive then
		return false
	end

	self.inputMap:call("select")
end

function SelectView:canUpdate()
	local canUpdate = not self.modal
	canUpdate = canUpdate and (not self.mainMenuView:isActive())

	return canUpdate
end

function SelectView:receive(event)
	self.game.selectController:receive(event)
	self.chartPreviewView:receive(event)

	if event.name == "keypressed" then
		if self.inputMap:call("view") then
			return
		end

		if self.screenX == 0 then
			self:songSelectInputs()
		end
	end
end

function SelectView:quit()
	if self.mainMenuView:isActive() then
		self.mainMenuView:toggle()
	end
end

function SelectView:resolutionUpdated()
	window_height = self.assets.localization:updateScale()
end

function SelectView:draw()
	local position = self.screenX
	local settings = self.settingsViewConfig
	local songSelect = self.songSelectViewConfig
	local collections = self.collectionsViewConfig

	songSelect.layoutDraw(position, songSelectOffset)
	settings.layoutDraw(position - 1)
	collections.layoutDraw(position + 1)

	local panelsStencil = function()
		if songSelect:canDraw(position) then
			songSelect.panels()
		end

		if settings.canDraw(position - 1) then
			settings.panels()
		end

		if collections.canDraw(position + 1) then
			collections.panels()
		end
	end

	gyatt.setTextScale(1080 / window_height)

	local function UI()
		songSelect:draw(self, position)
		collections:draw(self, position + 1)
		settings:draw(self, position - 1)
		self.headerView:draw(self)
	end

	self.layersView:draw(panelsStencil, UI)
	self.mainMenuView:draw("select", self)
	self:drawModal()
	self.notificationView:draw()

	gyatt.setTextScale(1)
end

return SelectView
