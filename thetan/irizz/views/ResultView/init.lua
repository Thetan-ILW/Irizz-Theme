local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local table_util = require("table_util")
local math_util = require("math_util")
local assets = require("thetan.irizz.assets")

local Theme = require("thetan.irizz.views.Theme")
local Header = require("thetan.irizz.views.HeaderView")
local Layout = require("thetan.irizz.views.ResultView.Layout")
local ViewConfig = require("thetan.irizz.views.ResultView.ViewConfig")
local OsuViewConfig = require("thetan.irizz.views.ResultView.OsuViewConfig")
local LayersView = require("thetan.irizz.views.LayersView")

local InputMap = require("thetan.irizz.views.ResultView.InputMap")

---@class thetan.irizz.ResultView: sphere.ScreenView
---@operator call: thetan.irizz.ResultView
local ResultView = ScreenView + {}

ResultView.currentJudgeName = ""
ResultView.currentJudge = 0

local osuSkin = nil

local loading = false
local canDraw = false
ResultView.load = thread.coro(function(self)
	if loading then
		return
	end

	loading = true

	self.game.resultController:load()

	local actionModel = self.game.actionModel
	self.inputMap = InputMap(self, actionModel)

	local audioSource = "preview"

	if self.game.gameView:getViewName(self.prevView) == "gameplay" then
		audioSource = "gameplay"
	end

	self.layersView = LayersView(self.game, "result", audioSource)

	if self.prevView == self.game.selectView then
		self.game.resultController:replayNoteChartAsync("result", self.game.selectModel.scoreItem)
	end

	local configs = self.game.configModel.configs
	local select = configs.select
	local irizz = configs.irizz
	local selected_osu_skin = irizz.osuResultSkin

	if irizz.osuResultScreen then
		if not osuSkin or osuSkin.name ~= selected_osu_skin then
			osuSkin = assets:getOsuResultAssets(Theme.osuSkins[selected_osu_skin])
			osuSkin.name = selected_osu_skin
		end

		self.viewConfig = OsuViewConfig(self.game, osuSkin)
		self.header = nil
	else
		self.viewConfig = ViewConfig(self.game, Theme.resultCustomConfig)
		self.header = Header(self.game, "result")
		self.viewConfig.scoreListView:reloadItems()
	end

	self:updateJudgements()

	self.currentJudgeName = select.judgements
	self.currentJudge = irizz.judge

	if not self.judgements[self.currentJudgeName] then
		local k, _ = next(self.judgements)
		select.judgements = k
		self.currentJudgeName = k
	end

	self.viewConfig:loadScore(self)

	canDraw = true
	loading = false
end)

function ResultView:updateJudgements()
	local scoreSystems = self.game.rhythmModel.scoreEngine.scoreSystem
	self.selectors = {
		scoreSystems["soundsphere"].metadata,
		scoreSystems["quaver"].metadata,
		scoreSystems["osuMania"].metadata,
		scoreSystems["etterna"].metadata,
	}

	self.judgements = {}

	for _, scoreSystem in pairs(scoreSystems) do
		table_util.copy(scoreSystem.judges, self.judgements)
	end

	local judgementScoreSystem = scoreSystems["judgement"]
	for _, judge in ipairs(judgementScoreSystem.judgementList) do
		table.insert(self.selectors, judge)
		table_util.copy(judgementScoreSystem.judges[judge.name], self.judgements)
	end
end

function ResultView:update()
	self.layersView:update()
	self.game.previewModel:update()
end

function ResultView:draw()
	Layout:draw()

	if not canDraw then
		return
	end

	local function panels()
		self.viewConfig.panels()
	end

	local function UI()
		if self.header then
			self.header:draw(self)
		end
		self.viewConfig:draw(self)
	end

	self.layersView:draw(panels, UI)
end

function ResultView:receive(event)
	if event.name == "keypressed" then
		self.inputMap:call("view")
	end
end

function ResultView:submitScore()
	local scoreItem = self.game.selectModel.scoreItem
	self.game.onlineModel.onlineScoreManager:submit(self.game.selectModel.chartview, scoreItem.replay_hash)
end

function ResultView:quit()
	self.game.rhythmModel.audioEngine:unload()
	self:changeScreen("selectView")
end

ResultView.loadScore = thread.coro(function(self, itemIndex)
	if loading then
		return
	end

	loading = true

	local scoreEntry = self.game.selectModel.scoreItem
	if itemIndex then
		scoreEntry = self.game.selectModel.scoreLibrary.items[itemIndex]
	end
	self.game.resultController:replayNoteChartAsync("result", scoreEntry)

	if itemIndex then
		self.game.selectModel:scrollScore(nil, itemIndex)
		self:updateJudgements()
	end

	self.viewConfig:loadScore(self)

	loading = false
end)

local playing = false
ResultView.play = thread.coro(function(self, mode)
	if playing then
		return
	end

	self.game.rhythmModel.audioEngine:unload()

	playing = true
	local scoreEntry = self.game.selectModel.scoreItem
	local isResult = self.game.resultController:replayNoteChartAsync(mode, scoreEntry)

	if isResult then
		return self.view:reload()
	end

	self:changeScreen("gameplayView")
	playing = false
end)

function ResultView:switchJudge(direction)
	local configs = self.game.configModel.configs
	local irizz = configs.irizz

	local scoreSystems = self.game.rhythmModel.scoreEngine.scoreSystem
	local ss = irizz.scoreSystem

	local scoreSystem

	if ss == "Soundsphere" then
		return
	elseif ss == "osu!mania" then
		scoreSystem = scoreSystems.osuMania
	elseif ss == "Etterna" then
		scoreSystem = scoreSystems.etterna
	elseif ss == "Quaver" then
		return
	end

	self.currentJudge =
		math_util.clamp(self.currentJudge + direction, scoreSystem.metadata.range[1], scoreSystem.metadata.range[2])

	self.currentJudgeName = scoreSystem.metadata.name:format(self.currentJudge)
	self.viewConfig:loadScore(self)
end

return ResultView
