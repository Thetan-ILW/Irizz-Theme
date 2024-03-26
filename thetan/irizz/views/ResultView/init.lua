local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")

local BackgroundView = require("sphere.views.BackgroundView")
local Header = require("thetan.irizz.views.HeaderView")
local Layout = require("thetan.irizz.views.ResultView.Layout")
local ViewConfig = require("thetan.irizz.views.ResultView.ViewConfig")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local InputMap = require("thetan.irizz.views.ResultView.InputMap")
local Theme = require("thetan.irizz.views.Theme")

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
	self.inputMap = InputMap(self, Theme.actions.resultScreen)

	if self.prevView == self.game.selectView then
		self.game.resultController:replayNoteChartAsync("result", self.game.selectModel.scoreItem)
	end

	self.header = Header(self.game, "result")
	self.viewConfig = ViewConfig(self.game)
	canDraw = true
	loading = false
end)

function ResultView:quit()
	self.game.rhythmModel.audioEngine:unload()
	self:changeScreen("selectView")
end

function ResultView:update()
	self.inputMap:call("view")
end

function ResultView:draw()
	Layout:draw()

	local configs = self.game.configModel.configs
	local graphics = configs.settings.graphics
	local irizz = configs.irizz

	local dim = graphics.dim.select
	local backgroundBlur = graphics.blur.select

	local panelBlur = irizz.panelBlur

	local w, h = Layout:move("background")

	BackgroundView:draw(w, h, dim, 0.01)

	if not canDraw then
		return
	end

	love.graphics.stencil(self.viewConfig.panels, "replace", 1)

	love.graphics.setStencilTest("greater", 0)

	w, h = Layout:move("background")
	GaussianBlurView:draw(panelBlur)
	BackgroundView:draw(w, h, dim, 0.01)
	GaussianBlurView:draw(panelBlur)

	love.graphics.setStencilTest()

	self.header:draw(self)
	self.viewConfig:draw(self)
end

function ResultView:submitScore()
	local scoreItem = self.game.selectModel.scoreItem
	self.game.onlineModel.onlineScoreManager:submit(
		self.game.selectModel.chartview,
		scoreItem.replay_hash
	)
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
