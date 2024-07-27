local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.FiltersModal.ViewConfig")

local FiltersModal = Modal + {}

FiltersModal.name = "FiltersModal"

function FiltersModal:onQuit()
	if self.game.selectView:isInOsuDirect() then
		return
	end

	self.game.selectModel:noDebouncePullNoteChartSet()
	self.game.selectModel:pullScore()
	self.game.selectView:updateFilterLines()
end

function FiltersModal:onShow()
	self.viewConfig.osuDirect = self.mainView:isInOsuDirect()
end

function FiltersModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(assets)
end

return FiltersModal
