local ScreenView = require("thetan.skibidi.views.ScreenView")

local ViewConfig = require("thetan.osu.views.SelectView.ViewConfig")
local MainMenuView = require("thetan.irizz.views.MainMenuView")
local LayersView = require("thetan.irizz.views.LayersView")

local OsuSelectAssets = require("thetan.osu.views.SelectView.OsuSelectAssets")

local ChartPreviewView = require("sphere.views.SelectView.ChartPreviewView")

local InputMap = require("thetan.osu.views.SelectView.InputMap")

---@class irizz.OsuSelectView: skibidi.ScreenView
---@operator call: irizz.OsuSelectView
local OsuSelectView = ScreenView + {}

function OsuSelectView:load()
	self.game.selectController:load(self)

	self.chartPreviewView = ChartPreviewView(self.game)
	self.chartPreviewView:load()

	self.selectModel = self.game.selectModel

	self.inputMap = InputMap(self, self.actionModel)
	self.actionModel.enable()

	self:setAssets()

	self.viewConfig = ViewConfig(self.game, self.assets)
	self.mainMenuView = MainMenuView(self)
	self.layersView = LayersView(self.game, self.mainMenuView, "select", "preview")

	local configs = self.game.configModel.configs
	local irizz = configs.irizz

	if irizz.showFreshInstallModal then
		local new_songs = self.game.cacheModel.newSongs
		local can_add_songs = #new_songs ~= 0

		if can_add_songs then
			self.gameView:openModal("thetan.irizz.views.modals.FreshInstallModal")
		end
	end
end

function OsuSelectView:setAssets()
	local configs = self.game.configModel.configs
	local irizz = configs.irizz

	---@type string
	local skin_path = ("userdata/skins/%s/"):format(irizz.osuSongSelectSkin)

	---@type skibidi.Assets?
	local assets = self.assetModel:get("osuSelect")

	if not assets or (assets and assets.skinPath ~= skin_path) then
		assets = OsuSelectAssets(skin_path)
		self.assetModel:store("osuSelect", assets)
	end

	---@cast assets osu.OsuSelectAssets
	self.assets = assets
	self.assets:updateVolume(self.game.configModel)
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

	self.assets:updateVolume(self.game.configModel)

	self.viewConfig:setFocus(self.modal == nil)

	self.game.selectController:update()

	self.layersView:update()
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

local previous_collections_group = "charts"

---@param name "charts" | "locations" | "directories"
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
end

function OsuSelectView:quit()
	if self.mainMenuView:isActive() then
		self.mainMenuView:toggle()
	end
end

local gfx = love.graphics

function OsuSelectView:drawCursor()
	gfx.origin()

	local x, y = love.mouse.getPosition()

	local cursor = self.assets.images.cursor
	local iw, ih = cursor:getDimensions()
	gfx.draw(cursor, x - iw / 2, y - ih / 2)
end

function OsuSelectView:resolutionUpdated()
	self.assets.localization:updateScale(gfx.getHeight() / 768)

	self.viewConfig:resolutionUpdated()

	if self.modal then
		self.modal.viewConfig:resolutionUpdated()
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
	self.notificationView:draw()
	self:drawCursor()
end

return OsuSelectView
