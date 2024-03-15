local Modal = require("thetan.iris.views.modals.Modal")
local ViewConfig = require("thetan.iris.views.modals.FiltersModal.ViewConfig")

local FiltersModal = Modal + {}

FiltersModal.name = "InputModal"
FiltersModal.viewConfig = ViewConfig()

function FiltersModal:onHide()
	local filterModel = self.game.selectModel.filterModel

	filterModel:apply()
	self.game.selectModel:noDebouncePullNoteChartSet()
end

function FiltersModal:new(game)
	self.game = game
end

return FiltersModal
