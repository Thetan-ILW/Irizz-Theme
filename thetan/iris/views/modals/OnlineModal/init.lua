local Modal = require("thetan.iris.views.modals.Modal")

local ViewConfig = require("thetan.iris.views.modals.OnlineModal.ViewConfig")

local OnlineModal = Modal + {}

OnlineModal.viewConfig = ViewConfig

function OnlineModal:new(game)
    self.game = game
end

return OnlineModal