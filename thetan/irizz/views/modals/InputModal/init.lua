local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.InputModal.ViewConfig")
local InputListView = require("thetan.irizz.views.modals.InputModal.InputListView")

local InputModal = Modal + {}

InputModal.name = "InputModal"
InputModal.viewConfig = ViewConfig

function InputModal:new(game)
    self.game = game
    ViewConfig.inputListView = InputListView(game)
end

return InputModal
