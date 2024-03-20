local SelectView = require("thetan.irizz.views.SelectView")
local ResultView = require("thetan.irizz.views.ResultView")
local GameView = require("thetan.irizz.views.GameView")

local modulePatcher = require("ModulePatcher")

modulePatcher:observe("sphere.controllers.GameController", "load", function(_self, game)
		game.ui.gameView = GameView(game)
		game.gameView = game.ui.gameView

		game.ui.selectView = SelectView()
		game.ui.selectView.game = game
		game.selectView = game.ui.selectView

		game.ui.resultView = ResultView()
		game.ui.resultView.game = game
		game.resultView = game.ui.resultView
end, nil)
