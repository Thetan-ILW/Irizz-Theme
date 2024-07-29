local NotificationModel = require("sphere.ui.NotificationModel")
local ThemeModel = require("sphere.ui.ThemeModel")
local BackgroundModel = require("sphere.ui.BackgroundModel")
local PreviewModel = require("sphere.ui.PreviewModel")
local ChartPreviewModel = require("sphere.ui.ChartPreviewModel")

local GameView = require("thetan.irizz.views.GameView")
local SelectView = require("thetan.irizz.views.SelectView")
local OsuSelectView = require("thetan.osu.views.SelectView")
local GameplayView = require("thetan.irizz.views.GameplayView")
local ResultView = require("thetan.irizz.views.ResultView")
local OsuResultView = require("thetan.osu.views.ResultView")
--local MultiplayerView = require("thetan.irizz.views.MultiplayerView")
local EditorView = require("sphere.views.EditorView")

local load_irizz_assets = require("thetan.irizz.assets_loader")

local UserInterface = require("sphere.ui.UserInterface")

function UserInterface:new(persistence, game)
	self.backgroundModel = BackgroundModel()
	self.notificationModel = NotificationModel()
	self.previewModel = PreviewModel(persistence.configModel)
	self.chartPreviewModel = ChartPreviewModel(persistence.configModel, self.previewModel, game)
	self.themeModel = ThemeModel()

	self.gameView = GameView(game)
	self.gameplayView = GameplayView(game)
	--self.multiplayerView = MultiplayerView(game)
	self.editorView = EditorView(game)

	self.persistence = persistence
	self.game = game
end

local base_load = UserInterface.load

function UserInterface:load()
	local irizz_config = self.persistence.configModel.configs.irizz

	local osu_ss = OsuSelectView(self.game)
	local irizz_ss = SelectView(self.game)

	local osu_result = OsuResultView(self.game)
	local irizz_result = ResultView(self.game)

	load_irizz_assets(self.game)

	self.selectView = irizz_config.osuSongSelect and osu_ss or irizz_ss
	self.resultView = irizz_config.osuResultScreen and osu_result or irizz_result

	self.game.selectView = self.selectView
	self.game.resultView = self.resultView

	base_load(self)
end
