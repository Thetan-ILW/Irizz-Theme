local SelectView = require("thetan.iris.views.SelectView")

local IrisTheme = {
    name = "thetan.IrisTheme2"
}

function IrisTheme:init()
    local modulePatcher = require("ModulePatcher")

    modulePatcher:observe("sphere.controllers.GameController", "load", function(_self, game)
        game.ui.selectView = SelectView()
        game.ui.selectView.game = game
        game.selectView = game.ui.selectView
    end, self)
end

return IrisTheme