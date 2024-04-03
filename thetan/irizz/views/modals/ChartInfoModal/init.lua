local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.ChartInfoModal.ViewConfig")

local ChartInfoModal = Modal + {}

ChartInfoModal.name = "ChartInfoModal"
ChartInfoModal.viewConfig = ViewConfig()

function ChartInfoModal:new(game)
	self.game = game
end

function ChartInfoModal:onShow()
	local items = self.game.selectModel.noteChartLibrary.items
	local index = self.game.selectModel.chartview_index

	self.item = items[index]
end

return ChartInfoModal
