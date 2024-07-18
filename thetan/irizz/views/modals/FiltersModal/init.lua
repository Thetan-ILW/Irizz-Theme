local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.FiltersModal.ViewConfig")

local FiltersModal = Modal + {}

FiltersModal.name = "FiltersModal"
FiltersModal.viewConfig = ViewConfig()

function FiltersModal:onQuit()
	if self.game.selectView:isInOsuDirect() then
		return
	end

	self.game.selectModel:noDebouncePullNoteChartSet()
	self.game.selectModel:pullScore()
	self.game.selectView:updateFilterLines()
end

function FiltersModal:onShow()
	if self.game.selectView.isInOsuDirect then
		self.viewConfig.osuDirect = self.game.selectView:isInOsuDirect()
	end
end

function FiltersModal:new(game)
	self.game = game
end

return FiltersModal
