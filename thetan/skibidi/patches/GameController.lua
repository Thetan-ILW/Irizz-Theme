local ActionModel = require("thetan.skibidi.models.ActionModel")
local SelectView = require("thetan.irizz.views.SelectView")
local OsuSelectView = require("thetan.osu.views.SelectView")
local GameplayView = require("thetan.irizz.views.GameplayView")
local ResultView = require("thetan.irizz.views.ResultView")
local MultiplayerView = require("thetan.irizz.views.MultiplayerView")
local OsuApi = require("thetan.skibidi.models.OsuApi")
local GameView = require("thetan.irizz.views.GameView")

local modulePatcher = require("ModulePatcher")
local module = "sphere.controllers.GameController"

modulePatcher:insert(module, "load", function(self)
	self.actionModel = ActionModel(self.persistence.configModel)

	self.ui.gameView = GameView(self)
	self.gameView = self.ui.gameView

	self.ui.resultView = ResultView(self)
	self.resultView = self.ui.resultView

	self.ui.gameplayView = GameplayView(self)
	self.gameplayView = self.ui.gameplayView

	self.ui.multiplayerView = MultiplayerView(self)
	self.multiplayerView = self.ui.multiplayerView

	self.osuApi = OsuApi(self)

	self.persistence:load()
	self.app:load()

	local configModel = self.configModel
	local rhythmModel = self.rhythmModel

	if configModel.configs.irizz.osuSongSelect then
		self.ui.selectView = OsuSelectView(self)
	else
		self.ui.selectView = SelectView(self)
	end

	self.selectView = self.ui.selectView

	rhythmModel.judgements = configModel.configs.judgements
	rhythmModel.hp = configModel.configs.settings.gameplay.hp
	rhythmModel.settings = configModel.configs.settings

	self.playContext:load(configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.onlineModel:load()
	self.noteSkinModel:load()
	self.osudirectModel:load()
	self.selectModel:load()
	table.insert(self.selectModel.scoreLibrary.scoreSources, "osu")

	self.multiplayerController:load()

	self.onlineModel.authManager:checkSession()
	self.multiplayerModel:connect()

	self.actionModel:load()
	self.osuApi:load()

	self.ui:load()
end)
