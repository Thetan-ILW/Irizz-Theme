local ScreenView = require("thetan.skibidi.views.ScreenView")
local thread = require("thread")
local math_util = require("math_util")
local gyatt = require("thetan.gyatt")

local get_assets = require("thetan.irizz.assets_loader")

local Header = require("thetan.irizz.views.HeaderView")
local Layout = require("thetan.irizz.views.ResultView.Layout")
local ViewConfig = require("thetan.irizz.views.ResultView.ViewConfig")
local LayersView = require("thetan.irizz.views.LayersView")

local InputMap = require("thetan.irizz.views.ResultView.InputMap")

---@class irizz.ResultView: skibidi.ScreenView
---@operator call: irizz.ResultView
local ResultView = ScreenView + {}

ResultView.currentJudgeName = ""
ResultView.currentJudge = 0

local window_height = 0

local loading = false
local canDraw = false
ResultView.load = thread.coro(function(self)
	if loading then
		return
	end

	loading = true

	self.game.resultController:load()

	local action_model = self.game.actionModel
	self.inputMap = InputMap(self, action_model)

	local audio_source = "preview"

	local is_after_gameplay = self.game.gameView:getViewName(self.prevView) == "gameplay"

	if is_after_gameplay then
		audio_source = "gameplay"
		local audio_engine = self.game.rhythmModel.audioEngine
		local music_volume = (audio_engine.volume.master * audio_engine.volume.music) * 0.3
		local effects_volume = (audio_engine.volume.master * audio_engine.volume.effects) * 0.3

		audio_engine.backgroundContainer:setVolume(music_volume)
		audio_engine.foregroundContainer:setVolume(effects_volume)
	end

	self.layersView = LayersView(self.game, "result", audio_source)

	if self.prevView == self.game.selectView then
		self.game.resultController:replayNoteChartAsync("result", self.game.selectModel.scoreItem)
	end

	local configs = self.game.configModel.configs
	local select = configs.select
	local irizz = configs.irizz

	self.assets = get_assets(self.game)

	self.viewConfig = ViewConfig(self.game, self.assets)
	self.header = Header(self.game, self.assets, "result")
	self.viewConfig.scoreListView:reloadItems()

	self.judgements = self.game.rhythmModel.scoreEngine.scoreSystem.judgements
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

	self:resolutionUpdated()
end)

function ResultView:unload()
	self.viewConfig:unload()
end

function ResultView:update()
	self.layersView:update()
	self.game.previewModel:update()
end

function ResultView:resolutionUpdated()
	window_height = self.assets.localization:updateScale()
end

function ResultView:draw()
	Layout:draw()

	gyatt.setTextScale(1080 / window_height)

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

	if ss == "osu!mania" then
		scoreSystem = scoreSystems.osuMania
	elseif ss == "osu!legacy" then
		scoreSystem = scoreSystems.osuLegacy
	elseif ss == "Etterna" then
		scoreSystem = scoreSystems.etterna
	elseif ss == "Lunatic rave 2" then
		scoreSystem = scoreSystems.lr2
	end

	if not scoreSystem then
		return
	end

	self.currentJudge =
		math_util.clamp(self.currentJudge + direction, scoreSystem.metadata.range[1], scoreSystem.metadata.range[2])

	local alias = scoreSystem.metadata.rangeValueAlias

	if alias then
		self.currentJudgeName = scoreSystem.metadata.name:format(alias[self.currentJudge])
	else
		self.currentJudgeName = scoreSystem.metadata.name:format(self.currentJudge)
	end

	self.viewConfig:loadScore(self)
end

function ResultView:scrollScore(delta)
	self.viewConfig:scrollScore(self, delta)
end

return ResultView
