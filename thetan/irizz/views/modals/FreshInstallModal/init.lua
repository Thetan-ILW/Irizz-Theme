local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.FreshInstallModal.ViewConfig")

local FreshInstallModal = Modal + {}

FreshInstallModal.name = "FreshInstallModal"
FreshInstallModal.newSongs = {}
FreshInstallModal.mountAndCache = false

function FreshInstallModal:new(game)
	self.game = game
	self.newSongs = self.game.cacheModel.newSongs

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(assets)
end

function FreshInstallModal:onQuit()
	local configs = self.game.configModel.configs
	local settings = configs.settings
	local ss = settings.select

	self.game.selectModel.collectionLibrary:load(ss.locations_in_collections)
	self.game.selectModel:noDebouncePullNoteChartSet()
	self.game.cacheModel.newSongs = {}
end

local index = 1

function FreshInstallModal:update()
	if not self.mountAndCache then
		return
	end

	if self.game.cacheModel.isProcessing then
		return
	end

	local songs = self.newSongs[index]

	if not songs then
		self.mountAndCache = false
		self:quit()
		return
	end

	local locationsRepo = self.game.cacheModel.locationsRepo
	local locationManager = self.game.cacheModel.locationManager

	local location = locationsRepo:insertLocation({
		name = songs[1],
		is_relative = false,
		is_internal = false,
	})

	locationManager:selectLocations()
	locationManager:selectLocation(location.id)
	locationManager:updateLocationPath(songs[2])

	self.game.selectController:updateCacheLocation(location.id)

	index = index + 1
end

return FreshInstallModal
