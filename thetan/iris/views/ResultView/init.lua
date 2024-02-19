local just = require("just")

local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")

local BackgroundView = require("sphere.views.BackgroundView")
local Header = require("thetan.iris.views.HeaderView")
local Layout = require("thetan.iris.views.ResultView.Layout")
local ViewConfig = require("thetan.iris.views.ResultView.ViewConfig")

---@class thetan.iris.ResultView: sphere.ScreenView
---@operator call: thetan.iris.ResultView
local ResultView = ScreenView + {}

local loading = false
local canDraw = false
ResultView.load = thread.coro(function(self)
	if loading then
		return
	end

	loading = true
	self.game.resultController:load()

	if self.prevView == self.game.selectView then
		self.game.resultController:replayNoteChartAsync("result", self.game.selectModel.scoreItem)
	end

	self.header = Header(self.game, "result")
	self.viewConfig = ViewConfig(self.game)
	canDraw = true
	loading = false
end)

function ResultView:update(dt)
	if just.keypressed("escape") then
		self:changeScreen("selectView")
	end
end

function ResultView:draw()
	Layout:draw()

	local w, h = Layout:move("background")
	local dim = self.game.configModel.configs.settings.graphics.dim.select
	BackgroundView:draw(w, h, dim, 0.01)

	if not canDraw then
		return
	end

	self.header:draw(self)
	self.viewConfig:draw(self)
end

ResultView.loadScore = thread.coro(function(self, itemIndex)
	if loading then
		return
	end

	loading = true
	local scoreEntry = self.game.selectModel.scoreItem

	if itemIndex then
		scoreEntry = self.game.scoreLibraryModel.items[itemIndex]
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

function ResultView:quit()
	self:changeScreen("selectView")
end

return ResultView
