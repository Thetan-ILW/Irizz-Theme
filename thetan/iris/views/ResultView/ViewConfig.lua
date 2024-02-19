local class = require("class")
local just = require("just")
local Format = require("sphere.views.Format")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local font

local Layout = require("thetan.iris.views.ResultView.Layout")

local ScoreListView = require("thetan.iris.views.ScoreListView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")

local ViewConfig = class()

function ViewConfig:new(game)
	self.scoreListView = ScoreListView(game, true)
	font = Theme:getFonts("resultView")
end

---@param view table
---@return boolean
local function showLoadedScore(view)
	local scoreEntry = view.game.playContext.scoreEntry
	local scoreItem = view.game.selectModel.scoreItem
	if not scoreEntry or not scoreItem then
		return false
	end
	return scoreItem.id == scoreEntry.id
end

function ViewConfig:scores(view)
	local w, h = Layout:move("gyattScores")
	Theme:panel(w, h)
	local list = self.scoreListView
	list:draw(w, h, true)
	Theme:border(w, h)
	if list.openResult then
		list.openResult = false
		view:loadScore(list.selectedScoreIndex)
	end
end

local pointR = 4

---@param self table
local function drawGraph(self)
	local w, h = Layout:move("hitGraph")
	love.graphics.translate(pointR, pointR)
	self.__index.draw(self, w - pointR, h - pointR)
	love.graphics.translate(-pointR, -pointR)
end

local perfectColor = Color.hitPerfect
local notPerfectColor = Color.hitBad
local _HitGraph = PointGraphView({
	draw = drawGraph,
	radius = pointR,
	backgroundColor = { 0, 0, 0, 0.2 },
	backgroundRadius = 6,
	point = function(self, point)
		if point.base.isMiss then
			return
		end
		local color = notPerfectColor
		if math.abs(point.misc.deltaTime) <= 0.016 then
			color = perfectColor
		end

		local y = point.misc.deltaTime / 0.16 / 2 + 0.5
		return y, unpack(color)
	end,
	show = showLoadedScore
})

local _EarlyHitGraph = PointGraphView({
	draw = drawGraph,
	radius = pointR,
	backgroundColor = { 0, 0, 0, 1 },
	backgroundRadius = pointR + 4,
	point = function(self, point)
		if not point.base.isEarlyHit then
			return
		end
		local y = point.misc.deltaTime / 0.16 / 2 + 0.5
		return y, unpack(Color.hitMiss)
	end,
	show = showLoadedScore
})

local _MissGraph = PointGraphView({
	draw = drawGraph,
	radius = pointR,
	backgroundColor = { 0, 0, 0, 1 },
	backgroundRadius = pointR + 4,
	point = function(self, point)
		if not point.base.isMiss then
			return
		end
		local y = point.misc.deltaTime / 0.16 / 2 + 0.5
		return y, unpack(Color.hitMiss)
	end,
	show = showLoadedScore
})

---@param view table
local function HitGraph(view)
	local w, h = Layout:move("hitGraph")
	Theme:panel(w, h)
	_HitGraph.game = view.game
	_HitGraph:draw()
	_EarlyHitGraph.game = view.game
	_EarlyHitGraph:draw()
	_MissGraph.game = view.game
	_MissGraph:draw()
	Theme:border(w, h)
end

local function Footer(view)
	local noteChartItem = view.game.selectModel.noteChartItem

	if not noteChartItem then
		return
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.titleAndDifficulty)

	local w, h = Layout:move("footerTitle")
	just.text(string.format("%s - %s", noteChartItem.artist, noteChartItem.title), w)

	w, h = Layout:move("footerChartName")
	just.text(
		string.format(
			"[%s] [%s] %s",
			Format.inputMode(noteChartItem.inputMode),
			noteChartItem.creator,
			noteChartItem.name
		),
		w,
		true
	)
end

function ViewConfig:draw(view)
	just.origin()
	self:scores(view)
	HitGraph(view)
	Footer(view)
end

return ViewConfig
