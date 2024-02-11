local Modal = require("thetan.iris.views.modals.Modal")
local ViewConfig = require("thetan.iris.views.modals.InputModal.ViewConfig")

local InputModal = Modal + {}

InputModal.name = "InputModal"
InputModal.viewConfig = ViewConfig

function InputModal:new(game)
    self.game = game
end

return InputModal
