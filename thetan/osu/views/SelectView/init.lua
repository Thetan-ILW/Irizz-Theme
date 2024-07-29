local ScreenView = require("thetan.skibidi.views.ScreenView")

local gyatt = require("thetan.gyatt")

local get_assets = require("thetan.osu.views.assets_loader")

local OsuLayout = require("thetan.osu.views.OsuLayout")
local ViewConfig = require("thetan.osu.views.SelectView.ViewConfig")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local BackgroundView = require("sphere.views.BackgroundView")

local ChartPreviewView = require("sphere.views.SelectView.ChartPreviewView")

local InputMap = require("thetan.osu.views.SelectView.InputMap")

---@class osu.OsuSelectView: skibidi.ScreenView
---@operator call: osu.OsuSelectView
local OsuSelectView = ScreenView + {}

local window_height = 768
local dim = 0
local background_blur = 0

function OsuSelectView:load()
	self.game.selectController:load(self)

	self.chartPreviewView = ChartPreviewView(self.game)
	self.chartPreviewView:load()

	self.selectModel = self.game.selectModel

	self.inputMap = InputMap(self, self.actionModel)
	self.actionModel.enable()

	self.assets = get_assets(self.game)

	if self.assets.selectViewConfig then
		self.viewConfig = self.assets.selectViewConfig()(self.game, self.assets)
	else
		self.viewConfig = ViewConfig(self.game, self.assets)
	end

	BackgroundView.game = self.game

	self.game.selectModel.collectionLibrary:load(true)

	local configs = self.game.configModel.configs
	local irizz = configs.irizz

	if irizz.showFreshInstallModal then
		local new_songs = self.game.cacheModel.newSongs
		local can_add_songs = #new_songs ~= 0

		if can_add_songs then
			self.gameView:openModal("thetan.irizz.views.modals.FreshInstallModal")
		end
	end

	window_height = love.graphics.getHeight()
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

	local configs = self.game.configModel.configs
	local graphics = configs.settings.graphics
	local irizz = configs.irizz

	dim = graphics.dim.select
	background_blur = graphics.blur.select

	self.assets:updateVolume(self.game.configModel)

	self.viewConfig:setFocus(self.modal == nil)

	self.game.selectController:update()

	self.chartPreviewView:update(dt)
end

function OsuSelectView:notechartChanged()
	self.viewConfig:updateInfo(self)
end

function OsuSelectView:play()
	if not self.game.selectModel:notechartExists() then
		return
	end

	local multiplayer_model = self.game.multiplayerModel
	if multiplayer_model.room and not multiplayer_model.isPlaying then
		multiplayer_model:pushNotechart()
		self:changeScreen("multiplayerView")
		return
	end

	self:changeScreen("gameplayView")
end

function OsuSelectView:edit()
	if not self.game.selectModel:notechartExists() then
		return
	end

	self:changeScreen("editorView")
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

	local time_rate_model = self.game.timeRateModel

	---@type table
	local range = time_rate_model.range[g.rate_type]

	---@type number
	local new_rate = time_rate_model:get() + range[3] * delta

	if new_rate ~= time_rate_model:get() then
		self.game.modifierSelectModel:change()
		time_rate_model:set(new_rate)
		self.viewConfig:updateInfo(self)
	end
end

local selected_group = "charts"
local previous_collections_group = "locations"

---@param name "charts" | "locations" | "directories" | "last_visited_locations"
function OsuSelectView:changeGroup(name)
	if name == "charts" then
		self.game.selectModel:noDebouncePullNoteChartSet()
	elseif name == "locations" then
		if previous_collections_group ~= "locations" then
			self.game.selectModel.collectionLibrary:load(true)
		end

		self.viewConfig.collectionListView:reloadItems()
		previous_collections_group = name
	elseif name == "directories" then
		if previous_collections_group ~= "directories" then
			self.game.selectModel.collectionLibrary:load(false)
		end

		self.viewConfig.collectionListView:reloadItems()
		previous_collections_group = name
	elseif name == "last_visited_locations" then
		name = previous_collections_group
	end

	selected_group = name
	self.viewConfig:selectGroup(name)
end

function OsuSelectView:select()
	if selected_group == "charts" then
		self:play()
		return
	end

	self:changeGroup("charts")
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
end

function OsuSelectView:quit() end

local gfx = love.graphics

function OsuSelectView:drawCursor()
	gfx.origin()

	local x, y = love.mouse.getPosition()

	local cursor = self.assets.images.cursor
	local iw, ih = cursor:getDimensions()
	gfx.draw(cursor, x - iw / 2, y - ih / 2)
end

function OsuSelectView:resolutionUpdated()
	window_height = self.assets.localization:updateScale()

	self.viewConfig:resolutionUpdated()

	if self.modal then
		self.modal.viewConfig:resolutionUpdated()
	end
end

function OsuSelectView:draw()
	OsuLayout:draw()
	local w, h = OsuLayout:move("base")

	gyatt.setTextScale(768 / window_height)

	GaussianBlurView:draw(background_blur)
	BackgroundView:draw(w, h, dim, 0.01)
	GaussianBlurView:draw(background_blur)

	self.viewConfig:draw(self)

	self:drawModal()
	self.notificationView:draw()
	self:drawCursor()

	gyatt.setTextScale(1)
end

return OsuSelectView
