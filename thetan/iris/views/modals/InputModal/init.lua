local Modal = require("thetan.iris.views.modals.Modal")
local ViewConfig = require("thetan.iris.views.modals.InputModal.ViewConfig")
local InputListView = require("thetan.iris.views.modals.InputModal.InputListView")

local InputModal = Modal + {}

InputModal.name = "InputModal"
InputModal.viewConfig = ViewConfig

function InputModal:new(game)
    self.game = game
    ViewConfig.inputListView = InputListView(game)
end

return InputModal
