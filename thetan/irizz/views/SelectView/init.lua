local gyatt = require("thetan.gyatt")
local flux = require("flux")
local math_util = require("math_util")
local ScreenView = require("sphere.views.ScreenView")

local Theme = require("thetan.irizz.views.Theme")
local HeaderView = require("thetan.irizz.views.HeaderView")

local LayersView = require("thetan.irizz.views.LayersView")
local SettingsViewConfig = require("thetan.irizz.views.SelectView.Settings")
local SongSelectViewConfig = require("thetan.irizz.views.SelectView.SongSelect")
local CollectionViewConfig = require("thetan.irizz.views.SelectView.Collections")

local InputMap = require("thetan.irizz.views.SelectView.InputMap")

---@class irizz.SelectView: sphere.ScreenView
---@operator call: irizz.SelectView
local SelectView = ScreenView + {}

SelectView.modalActive = false
SelectView.screenX = 0
SelectView.screenXTarget = 0

SelectView.chartFilterLine = ""
SelectView.scoreFilterLine = ""

SelectView.openAnimationTween = nil
SelectView.openAnimationPercent = 0

local playSound = nil
function SelectView:load()
	self.game.selectController:load(self)
	self.headerView = HeaderView("select")
	self.settingsViewConfig = SettingsViewConfig(self.game)
	self.songSelectViewConfig = SongSelectViewConfig(self.game)
	self.collectionsViewConfig = CollectionViewConfig(self.game)
	self.selectModel = self.game.selectModel

	playSound = Theme:getStartSound(self.game)

	local actionModel = self.game.actionModel
	self.inputMap = InputMap(self, actionModel:getGroup("songSelect"))

	self:updateFilterLines()
	self.layersView = LayersView(self.game, "select", "preview")
	self.openAnimationTween = flux.to(self, 0.8, { openAnimationPercent = 1 }):ease("quadout")
end

function SelectView:beginUnload()
	self.game.selectController:beginUnload()
end

function SelectView:unload()
	self.game.selectController:unload()
	self.collectionsViewConfig = nil
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
	end

	Theme:playSound("songSelectScreenChanged")
end

---@param dt number
function SelectView:updateSettings(dt)
	playSound = Theme:getStartSound(self.game)
end

function SelectView:switchToSongSelect()
	self.game.selectModel:noDebouncePullNoteChartSet()
end

---@param dt number
function SelectView:update(dt)
	self.game.selectController:update()

	if self.screenX == 1 then
		self:updateSettings(dt)
	end

	self.layersView:update()
end

function SelectView:notechartChanged()
	self.songSelectViewConfig:updateInfo(self)
end

function SelectView:play()
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

function SelectView:openModal(name)
	self.game.gameView:openModal(name)
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

function SelectView:receive(event)
	self.game.selectController:receive(event)

	if event.name == "keypressed" then
		if self.inputMap:call("view") then
			return
		end

		if self.screenX == 0 then
			self:songSelectInputs()
		end
	end
end

function SelectView:draw()
	local position = self.screenX
	local settings = self.settingsViewConfig
	local songSelect = self.songSelectViewConfig
	local collections = self.collectionsViewConfig

	songSelect.layoutDraw(position)
	settings.layoutDraw(position - 1)
	collections.layoutDraw(position + 1)

	local panelsStencil = function()
		if songSelect.canDraw(position) then
			songSelect.panels()
		end

		if settings.canDraw(position - 1) then
			settings.panels()
		end

		if collections.canDraw(position + 1) then
			collections.panels()
		end
	end

	local function UI()
		self.headerView:draw(self)
		songSelect:draw(self, position)
		collections:draw(self, position + 1)
		settings:draw(self, position - 1)
	end

	self.layersView:draw(panelsStencil, UI)

	if not self.openAnimationTween then
		return
	end

	if self.openAnimationPercent == 1 then
		self.openAnimationTween = nil
	end

	local w, h = love.graphics.getDimensions()

	local animationStencil = function()
		love.graphics.circle("fill", 0, 0, (w * 1.5) * self.openAnimationPercent)
	end

	love.graphics.stencil(animationStencil, "replace", 1)
	love.graphics.setStencilTest("equal", 0)
	love.graphics.setColor(0, 0, 0, 1)

	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setStencilTest()
end

return SelectView
