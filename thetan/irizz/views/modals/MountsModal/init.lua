local Modal = require("thetan.irizz.views.modals.Modal")

local ViewConfig = require("thetan.irizz.views.modals.MountsModal.ViewConfig")
local MountsListView = require("thetan.irizz.views.modals.MountsModal.MountsListView")

local MountsModal = Modal + {}

MountsModal.viewConfig = ViewConfig

function MountsModal:new(game)
    self.game = game
    self.viewConfig.mountsListView = MountsListView(game)
end

return MountsModal
