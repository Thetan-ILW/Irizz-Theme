local SelectView = require("thetan.iris.views.SelectView")
local ResultView = require("thetan.iris.views.ResultView")
local GameView = require("thetan.iris.views.GameView")

local IrisTheme = {
	name = "thetan.IrisTheme",
}

function IrisTheme:init()
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
	end, self)
	
	local dirs = require("sphere.persistence.dirs")

	modulePatcher:insert("sphere.persistence.Persistence", "load", function(_self)
		dirs.create()

		local configModel = _self.configModel
		configModel:open("settings", true)
		configModel:open("select", true)
		configModel:open("play", true)
		configModel:open("input", true)
		configModel:open("online", true)
		configModel:open("urls")
		configModel:open("judgements")
		configModel:open("filters")
		configModel:open("files")
		configModel:open("iris", true)
		configModel:read()

		_self.cacheModel:load()
	end)
end

return IrisTheme
