local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.MultiplayerModal.ViewConfig")

local MultiplayerModal = Modal + {}

MultiplayerModal.name = "MultiplayerModal"
MultiplayerModal.viewConfig = nil

function MultiplayerModal:new(game)
    self.game = game
    self.viewConfig = ViewConfig(game)
end

return MultiplayerModal
