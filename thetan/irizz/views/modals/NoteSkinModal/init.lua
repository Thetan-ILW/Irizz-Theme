local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.NoteSkinModal.ViewConfig")
local NoteSkinListView = require("thetan.irizz.views.modals.NoteSkinModal.NoteSkinListView")

local NoteSkinModal = Modal + {}

NoteSkinModal.name = "NoteSkins"
NoteSkinModal.viewConfig = ViewConfig

function NoteSkinModal:new(game)
    self.game = game
    ViewConfig.noteSkinListView = NoteSkinListView(game)
end

return NoteSkinModal
