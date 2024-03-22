local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.FiltersModal.ViewConfig")

local FiltersModal = Modal + {}

FiltersModal.name = "FiltersModal"
FiltersModal.viewConfig = ViewConfig()

function FiltersModal:onHide()
	self.game.selectModel:noDebouncePullNoteChartSet()
	self.game.selectModel:pullScore()
	self.game.selectView:updateFilterLines()
end

function FiltersModal:new(game)
	self.game = game
end

return FiltersModal
