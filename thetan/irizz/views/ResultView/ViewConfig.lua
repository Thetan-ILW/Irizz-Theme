local class = require("class")
local just = require("just")
local gfx_util = require("gfx_util")
local Format = require("sphere.views.Format")
local erfunc = require("libchart.erfunc")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textResult
local font

local Layout = require("thetan.irizz.views.ResultView.Layout")

local ScoreListView = require("thetan.irizz.views.ScoreListView")
local PointGraphView = require("sphere.views.GameplayView.PointGraphView")

local ViewConfig = class()

function ViewConfig:new(game)
	self.scoreListView = ScoreListView(game, true)
	self.scoreListView.rows = 5
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

local lineList = {
	"line1",
	"line2",
	"line3",
	"line4",
	"line5"
}

function ViewConfig.panels()
	local w, h = Layout:move("panel")
	Theme:panel(w, h)
	w, h = Layout:move("hitGraph")
	Theme:panel(w, h)
end

local function borders()
	local w, h = Layout:move("hitGraph")
	Theme:border(w, h)

	w, h = Layout:move("panel")

	local function stencil()
		love.graphics.rectangle("fill", -100, 0, w + 200, h + 100)
	end

	love.graphics.stencil(stencil, "replace", 1)
	love.graphics.setStencilTest("greater", 0)
	Theme:border(w, h)
	love.graphics.setStencilTest()
end

local function lines()
	love.graphics.setColor(Color.border)
	for _, name in ipairs(lineList) do
		local w, h = Layout:move(name)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
end

local function printKeyValue(key, value, w, h, ay)
	ay = ay or "top"
	gfx_util.printFrame(("%s:"):format(key), 15, 15, w, h, "left", ay)
	gfx_util.printFrame(value, -15, 15, w, h, "right", ay)
end

function ViewConfig:scores(view)
	local w, h = Layout:move("scores")
	local list = self.scoreListView
	list:draw(w, h, true)
	if list.openResult then
		list.openResult = false
		view:loadScore(list.selectedScoreIndex)
	end
end

local pointR = 3
local padding = 5
---@param self table
local function drawGraph(self)
	local w, h = Layout:move("hitGraph")
	love.graphics.translate(pointR + padding, pointR)
	self.__index.draw(self, w - pointR - (padding * 2), h - pointR)
	love.graphics.translate(-pointR - padding, -pointR)
end

local function getPointY(y)
	return (y.misc.deltaTime / 0.27) + 0.5
end

local _HitGraph = PointGraphView({
	draw = drawGraph,
	radius = pointR,
	backgroundColor = { 0, 0, 0, 0.2 },
	backgroundRadius = 6,
	point = function(self, point)
		if point.base.isMiss then
			return
		end
		local y = getPointY(point)
		local color = Theme:getHitColor(point.misc.deltaTime, false)
		return y, unpack(color)
	end,
	show = showLoadedScore
})

local _EarlyHitGraph = PointGraphView({
	draw = drawGraph,
	radius = pointR,
	backgroundColor = { 0, 0, 0, 1 },
	backgroundRadius = 0,
	point = function(self, point)
		if not point.base.isEarlyHit then
			return
		end
		local y = getPointY(point)
		return y, unpack(Theme:getHitColor(0, true))
	end,
	show = showLoadedScore
})

local _MissGraph = PointGraphView({
	draw = drawGraph,
	radius = pointR,
	backgroundColor = { 0, 0, 0, 1 },
	backgroundRadius = 0,
	point = function(self, point)
		if not point.base.isMiss then
			return
		end
		local y = getPointY(point)
		return y, unpack(Theme:getHitColor(0, true))
	end,
	show = showLoadedScore
})

---@param view table
local function HitGraph(view)
	local w, h = Layout:move("hitGraph")
	_HitGraph.game = view.game
	_HitGraph:draw()
	_EarlyHitGraph.game = view.game
	_EarlyHitGraph:draw()
	_MissGraph.game = view.game
	_MissGraph:draw()

	local show = showLoadedScore(view)

	local rhythmModel = view.game.rhythmModel
	local scoreEngine = rhythmModel.scoreEngine
	local scoreItem = view.game.selectModel.scoreItem
	local normalscore = rhythmModel.scoreEngine.scoreSystem.normalscore
	local mean = show and normalscore.normalscore.mean or scoreItem.mean

	local meanText = string.format("Mean: %i ms", mean * 1000)
	local maxErrorText = string.format("Max error: %i ms", scoreEngine.scoreSystem.misc.maxDeltaTime * 1000)

	local fontHeight = font.hitError:getBaseline()
	Theme:panel(font.hitError:getWidth(meanText) + 10, fontHeight + 10)

	local fontWidth = font.hitError:getWidth(maxErrorText)
	love.graphics.rectangle("fill", 0, h - fontHeight - 10, fontWidth + 10, fontHeight + 10)

	just.indent(5)
	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.hitError)
	just.text(meanText, w)
	Layout:move("hitGraph")
	gfx_util.printFrame(maxErrorText, 5, -5, w, h, "left", "bottom")
end

---@param view table
function ViewConfig:judgements(view)
	local show = showLoadedScore(view)
	local scoreEngine = view.game.rhythmModel.scoreEngine
	local scoreItem = view.game.selectModel.scoreItem
	local judgement = scoreEngine.scoreSystem.judgement

	if not judgement or not scoreItem then
		return
	end

	local configs = view.game.configModel.configs
	local scoreSystem = configs.irizz.scoreSystem
	local judge = configs.irizz.judge
	local prefix = Theme.getPrefix(scoreSystem)
	local counterName = scoreSystem .. prefix .. judge

	local counters = judgement.counters
	local judgementLists = judgement.judgementLists
	local counter = counters[counterName]
	local judgements = judgement.judgements[counterName]
	local base = scoreEngine.scoreSystem.base

	local miss = show and base.missCount or scoreItem.miss or 0

	local w, h = Layout:move("judgements")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.judgements)

	local textHeight = font.judgements:getHeight()
	local textIndent = textHeight

	if show then
		for _, name in ipairs(judgementLists[counterName]) do
			local value = counters[counterName][name]
			printKeyValue(name:upper(), value, w, h)
			just.next(0, textIndent)
		end

		w, h = Layout:move("judgements")

		just.next(0, -textHeight + 5)
		printKeyValue("MISS", miss, w, h, "bottom")
	end

	w, h = Layout:move("judgementsAccuracy")
	love.graphics.setFont(font.accuracy)

	if not judgements.accuracy then
		gfx_util.printFrame(Text.noAccuracy, 0, 0, w, h, "center", "center")
		return
	end

	gfx_util.printFrame(("%s %s %3.2f%%"):format(scoreSystem, prefix..judge, judgements.accuracy(counter) * 100), 0, 0, w, h, "center", "center")
end

local function footer(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.titleAndDifficulty)

	local leftText = string.format("%s - %s", chartview.artist, chartview.title)
	local rightText = string.format(
		"[%s] [%s] %s",
		Format.inputMode(chartview.chartdiff_inputmode),
		chartview.creator or "",
		chartview.name
	)

	local w, h = Layout:move("footerTitle")
	Theme:textWithShadow(leftText, w, h, "left", "top")
	w, h = Layout:move("footerChartName")
	Theme:textWithShadow(rightText, w, h, "right", "top")
end

function ViewConfig:scoreInfo(view)
	local ratingHitTimingWindow = view.game.configModel.configs.settings.gameplay.ratingHitTimingWindow

	local rhythmModel = view.game.rhythmModel
	local normalscore = rhythmModel.scoreEngine.scoreSystem.normalscore

	local chartview = view.game.selectModel.chartview
	local scoreItem = view.game.selectModel.scoreItem
	local scoreEngine = rhythmModel.scoreEngine
	local playContext = view.game.playContext

	if not scoreItem then
		return
	end

	local scoreEntry = playContext.scoreEntry
	if not scoreEntry then
		return
	end

	local show = showLoadedScore(view)

	local baseTimeRate = show and playContext.rate or scoreItem.rate

	local inputMode = show and tostring(rhythmModel.noteChart.inputMode) or scoreItem.inputmode
	inputMode = Format.inputMode(inputMode)
	local score = not show and scoreItem.score or
		erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2))) * 10000
	if score ~= score then
		score = 0
	end

	local accuracyValue = show and normalscore.accuracyAdjusted or scoreItem.accuracy
	local accuracy = Format.accuracy(accuracyValue)

	local w, h = Layout:move("normalscore")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.scoreInfo)

	local textHeight = font.judgements:getHeight()
	local textIndent = textHeight + 8

	just.next(0, (h / 2)  - ((textIndent * 2) + 15))
	printKeyValue(Text.score, ("%i"):format(score), w, h)
	just.next(0, textIndent)
	printKeyValue(Text.accuracy, accuracy, w, h)
	just.next(0, textIndent)
	printKeyValue(Text.inputMode, inputMode, w, h)
	just.next(0, textIndent)
	printKeyValue(Text.timeRate, ("%0.02fx"):format(baseTimeRate), w, h)
end

function ViewConfig:difficulty(view)
	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Color.transparentPanel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	if not chartview.difficulty then
		return
	end

	local diffColumn = view.game.configModel.configs.settings.select.diff_column
	local baseTimeRate = view.game.playContext.rate

	w, h = Layout:move("difficulty")

	love.graphics.setColor(Theme:getDifficultyColor(chartview.difficulty * baseTimeRate, diffColumn))
	love.graphics.setFont(font.difficulty)
	gfx_util.printBaseline(string.format("%0.02f", chartview.difficulty * baseTimeRate), 0, h / 2, w, 1, "center")

	love.graphics.setFont(font.calculator)
	local calculator = Theme.formatDiffColumns(diffColumn)
	gfx_util.printBaseline(calculator, 0, h / 1.2, w, 1, "center")

	local patterns = chartview.msd_diff_data or Text.noPatterns
	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.patterns)
	w, h = Layout:move("patterns")
	gfx_util.printFrame(patterns, 0, 0, w, h, "center", "center")
end

function ViewConfig:pauses(view)
	local scoreItem = view.game.selectModel.scoreItem
	local playContext = view.game.playContext

	local show = showLoadedScore(view)
	local const = show and playContext.const or scoreItem.const
	local scrollSpeed = "X"
	if const then
		scrollSpeed = "Const"
	end

	local w, h = Layout:move("pauses")
	love.graphics.setFont(font.pauses)
	local textHeight = font.judgements:getHeight()

	just.next(0, -15)
	printKeyValue(Text.pauses, scoreItem.pauses, w, h)
	just.next(0, -textHeight + 30)
	printKeyValue(Text.scrollSpeed, scrollSpeed, w, h, "bottom")
end

function ViewConfig:modifiers(view)
	local selectModel = view.game.selectModel
	local modifiers = view.game.playContext.modifiers
	if not showLoadedScore(view) and selectModel.scoreItem then
		modifiers = selectModel.scoreItem.modifiers
	end

	local w, h = Layout:move("mods")
	local text = Theme:getModifierString(modifiers)
	love.graphics.setFont(font.modifiers)
	Theme:textWithShadow(text, w, h, "center", "center")
end

function ViewConfig:draw(view)
	just.origin()
	self.panels()
	lines()

	self:judgements(view)
	self:scores(view)
	self:difficulty(view)
	self:scoreInfo(view)
	self:pauses(view)
	self:modifiers(view)
	HitGraph(view)

	borders()
	footer(view)
end

return ViewConfig
