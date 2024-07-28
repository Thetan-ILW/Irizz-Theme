local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.FiltersModal.ViewConfig")

local FiltersModal = Modal + {}

FiltersModal.name = "FiltersModal"

function FiltersModal:onQuit()
	if self.mainView.isInOsuDirect and self.mainView:isInOsuDirect() then
		return
	end

	self.game.selectModel:noDebouncePullNoteChartSet()
	self.game.selectModel:pullScore()

	if self.mainView.updateFilterLines then
		self.game.selectView:updateFilterLines()
	end
end

function FiltersModal:onShow()
	if self.mainView.isInOsuDirect then
		self.viewConfig.osuDirect = self.mainView:isInOsuDirect()
	end
end

function FiltersModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(assets)
end

return FiltersModal
