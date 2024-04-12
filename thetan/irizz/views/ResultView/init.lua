local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local table_util = require("table_util")

local Header = require("thetan.irizz.views.HeaderView")
local Layout = require("thetan.irizz.views.ResultView.Layout")
local ViewConfig = require("thetan.irizz.views.ResultView.ViewConfig")
local LayersView = require("thetan.irizz.views.LayersView")

local InputMap = require("thetan.irizz.views.ResultView.InputMap")

---@class thetan.irizz.ResultView: sphere.ScreenView
---@operator call: thetan.irizz.ResultView
local ResultView = ScreenView + {}

local loading = false
local canDraw = false
ResultView.load = thread.coro(function(self)
	if loading then
		return
	end

	loading = true

	self.game.resultController:load()

	local actionModel = self.game.actionModel
	self.inputMap = InputMap(self, actionModel:getGroup("resultScreen"))

	local audioSource = "preview"

	if self.game.gameView:getViewName(self.prevView) == "gameplay" then
		audioSource = "gameplay"
	end

	self.layersView = LayersView(self.game, "result", audioSource)

	if self.prevView == self.game.selectView then
		self.game.resultController:replayNoteChartAsync("result", self.game.selectModel.scoreItem)
	end

	self.header = Header(self.game, "result")
	self.viewConfig = ViewConfig(self.game)

	self:updateJudgements()

	local config = self.game.configModel.configs.select
	local selectedJudgement = config.judgements

	if not self.judgements[selectedJudgement] then
		local k, _ = next(self.judgements)
		config.judgements = k
	end

	self.viewConfig:loadScore(self)
	self.viewConfig.scoreListView:reloadItems()

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
		self.header:draw(self)
		self.viewConfig:draw(self)
	end

	self.layersView:draw(panels, UI)
end

function ResultView:inputs()
	self.inputMap:call("view")
end

function ResultView:receive(event)
	if event.name == "keypressed" then
		self:inputs()
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

	playing = true
	local scoreEntry = self.game.selectModel.scoreItem
	local isResult = self.game.resultController:replayNoteChartAsync(mode, scoreEntry)

	if isResult then
		return self.view:reload()
	end

	self:changeScreen("gameplayView")
	playing = false
end)

return ResultView
