local Modal = require("thetan.iris.views.modals.Modal")
local ViewConfig = require("thetan.iris.views.modals.NoteSkinModal.ViewConfig")
local NoteSkinListView = require("thetan.iris.views.modals.NoteSkinModal.NoteSkinListView")

local NoteSkinModal = Modal + {}

NoteSkinModal.name = "NoteSkins"
NoteSkinModal.viewConfig = ViewConfig

function NoteSkinModal:new(game)
    self.game = game
    ViewConfig.noteSkinListView = NoteSkinListView(game)
end

return NoteSkinModal
