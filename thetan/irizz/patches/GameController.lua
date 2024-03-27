local ActionModel = require("thetan.irizz.models.ActionModel")
local SelectView = require("thetan.irizz.views.SelectView")
local ResultView = require("thetan.irizz.views.ResultView")
local GameView = require("thetan.irizz.views.GameView")

local modulePatcher = require("ModulePatcher")
local module= "sphere.controllers.GameController"

modulePatcher:insert(module, "load", function(self)
	self.actionModel = ActionModel(
		self.persistence.configModel
	)

	self.ui.gameView = GameView(self)
	self.gameView = self.ui.gameView

	self.ui.selectView = SelectView()
	self.ui.selectView.game = self
	self.selectView = self.ui.selectView

	self.ui.resultView = ResultView()
	self.ui.resultView.game = self
	self.resultView = self.ui.resultView

	self.persistence:load()
	self.app:load()

	local configModel = self.configModel
	local rhythmModel = self.rhythmModel

	rhythmModel.judgements = configModel.configs.judgements
	rhythmModel.hp = configModel.configs.settings.gameplay.hp
	rhythmModel.settings = configModel.configs.settings

	self.playContext:load(configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.onlineModel:load()
	self.noteSkinModel:load()
	self.osudirectModel:load()
	self.selectModel:load()

	self.multiplayerController:load()

	self.onlineModel.authManager:checkSession()
	self.multiplayerModel:connect()

	self.actionModel:load()

	self.ui:load()
end)
