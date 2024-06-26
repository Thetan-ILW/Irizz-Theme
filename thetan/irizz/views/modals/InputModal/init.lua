local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.InputModal.ViewConfig")
local InputListView = require("thetan.irizz.views.modals.InputModal.InputListView")

local InputModal = Modal + {}

InputModal.name = "InputModal"
InputModal.viewConfig = ViewConfig
InputModal.inputMode = ""

function InputModal:new(game)
	self.game = game
	ViewConfig.inputListView = InputListView(game)
end

function InputModal:onShow()
	self.inputMode = tostring(self.game.selectController.state.inputMode)
	self.viewConfig.inputListView.inputMode = self.inputMode
	self.viewConfig.inputListView:reloadItems()
end

return InputModal
