local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.InputModal.ViewConfig")

local InputModal = Modal + {}

InputModal.name = "InputModal"
InputModal.inputMode = ""

function InputModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(game, assets)
end

function InputModal:onShow()
	self.inputMode = tostring(self.game.selectController.state.inputMode)
	self.viewConfig.inputListView.inputMode = self.inputMode
	self.viewConfig.inputListView:reloadItems()
end

return InputModal
