local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")
local math_util = require("math_util")
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

local difficulty = 0
local patterns = ""
local calculator = ""
local difficultyColor = Color.text

local gfx = love.graphics

function ViewConfig:new(game)
	self.scoreListView = ScoreListView(game, true)
	self.scoreListView.rows = 5
	font = Theme:getFonts("resultView")
end

function ViewConfig:loadScore(view)
	local chartview = view.game.selectModel.chartview
	local chartdiff = view.game.playContext.chartdiff

	local diffColumn = view.game.configModel.configs.settings.select.diff_column
	local timeRate = view.game.playContext.rate

	difficulty = (chartview.difficulty or 0) * timeRate
	patterns = chartview.level and "Lv." .. chartview.level or Text.noPatterns

	if diffColumn == "msd_diff" and chartdiff.msd_diff_data then
		difficulty = chartdiff.msd_diff
		patterns = Theme.getMaxAndSecondFromSsr(chartdiff.msd_diff_data) or Text.noPatterns
	end

	difficultyColor = Theme:getDifficultyColor(difficulty, diffColumn)
	calculator = Theme.formatDiffColumns(diffColumn)
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

local boxes = {
	"scoringStats",
}

function ViewConfig.panels()
	for _, name in ipairs(boxes) do
		local w, h = Layout:move(name)
		Theme:border(w, h)
	end
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
	show = showLoadedScore,
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
	show = showLoadedScore,
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
	show = showLoadedScore,
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

	if not scoreItem then
		return
	end

	local normalscore = rhythmModel.scoreEngine.scoreSystem.normalscore
	local mean = show and normalscore.normalscore.mean or scoreItem.mean

	local meanText = string.format("Mean: %i ms", mean * 1000)
	local maxErrorText = string.format("Max error: %i ms", scoreEngine.scoreSystem.misc.maxDeltaTime * 1000)

	local fontHeight = font.hitError:getBaseline()
	Theme:panel(font.hitError:getWidth(meanText) + 10, fontHeight + 10)

	love.graphics.translate(0, h - fontHeight - 10)
	Theme:panel(font.hitError:getWidth(maxErrorText) + 10, fontHeight + 10)

	just.indent(5)
	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.hitError)
	Layout:move("hitGraph")
	just.text(meanText, w)
	Layout:move("hitGraph")
	gfx_util.printFrame(maxErrorText, 5, -5, w, h, "left", "bottom")
end

local function title(view)
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

	local w, h = Layout:move("title")
	Theme:textWithShadow(leftText, w, h, "center", "top")
	w, h = Layout:move("chartName")
	Theme:textWithShadow(rightText, w, h, "center", "bottom")
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

local function judgementCount(label, color, w, count, max)
	local label_height = font.counterName:getHeight()

	local bar_x = 4
	local bar_width = math_util.clamp(((count / max) * w) - (bar_x * 2), 0, w)

	local bar_height = label_height + 4

	color[4] = 0.4
	gfx.setColor(color)
	gfx.rectangle("fill", bar_x, 4, w - (bar_x * 2), bar_height, 4, 4)

	if bar_width > 4 then
		color[4] = 1
		gfx.setColor(color)
		gfx.rectangle("fill", bar_x, 4, bar_width, bar_height, 4, 4)
	end

	gfx.push()
	gfx.setColor(Color.text)
	gfx.translate(10, 4)
	Theme:textWithShadow(label, w, label_height, "left", "center")
	gfx.translate(-20, 0)
	Theme:textWithShadow(count, w, label_height, "right", "center")
	gfx.pop()

	gfx.translate(0, label_height + 8)
end

local counterColors = {
	soundsphere = {
		perfect = { 1, 1, 1, 1 },
		["not perfect"] = { 1, 0.6, 0.4, 1 },
	},
	osuMania = {
		perfect = { 0.6, 0.8, 1, 1 },
		great = { 0.95, 0.796, 0.188, 1 },
		good = { 0.07, 0.8, 0.56, 1 },
		ok = { 0.1, 0.39, 1, 1 },
		meh = { 0.42, 0.48, 0.51, 1 },
	},
	etterna = {
		marvelous = { 0.6, 0.8, 1, 1 },
		perfect = { 0.95, 0.796, 0.188, 1 },
		great = { 0.07, 0.8, 0.56, 1 },
		bad = { 0.1, 0.7, 1, 1 },
		boo = { 1, 0.1, 0.7, 1 },
	},
	quaver = {
		marvelous = { 1, 1, 0.71, 1 },
		perfect = { 1, 0.91, 0.44, 1 },
		great = { 0.38, 0.96, 0.47, 1 },
		good = { 0.25, 0.7, 0.75, 1 },
		okay = { 0.72, 0.46, 0.65, 1 },
	},
}

local function getCounterColors(judge_name)
	if string.find(judge_name, "osu!mania") then
		return counterColors["osuMania"]
	elseif string.find(judge_name, "Etterna") then
		return counterColors["etterna"]
	elseif string.find(judge_name, "Quaver") then
		return counterColors["quaver"]
	elseif string.find(judge_name, "Soundsphere") then
		return counterColors["soundsphere"]
	end

	error("No colors for this score system.")
end

local function GradeKV(label, v, w)
	just.indent(50)
	gyatt.text(label, w, "left")
	just.sameline()
	just.indent(-100)
	gyatt.text(v, w, "right")
end

local function getGrade(judge, accuracy)
	if string.find(judge, "osu!mania") then
		if accuracy == 1 then
			return "SS"
		elseif accuracy > 0.95 then
			return "S"
		elseif accuracy > 0.9 then
			return "A"
		elseif accuracy > 0.8 then
			return "B"
		elseif accuracy > 0.7 then
			return "C"
		else
			return "D"
		end
	elseif string.find(judge, "Etterna") then
		if accuracy > 0.999935 then
			return "AAAAA"
		elseif accuracy > 0.99955 then
			return "AAAA"
		elseif accuracy > 0.997 then
			return "AAA"
		elseif accuracy > 0.93 then
			return "AA"
		elseif accuracy > 0.8 then
			return "B"
		elseif accuracy > 0.7 then
			return "C"
		else
			return "F"
		end
	elseif string.find(judge, "Quaver") then
		if accuracy == 1 then
			return "X"
		elseif accuracy > 0.99 then
			return "SS"
		elseif accuracy > 0.95 then
			return "S"
		elseif accuracy > 0.9 then
			return "A"
		elseif accuracy > 0.8 then
			return "B"
		elseif accuracy > 0.7 then
			return "C"
		elseif accuracy > 0.6 then
			return "D"
		else
			return "F"
		end
	end

	return "-"
end

local function timingsKV(label, v, w)
	just.indent(15)
	gyatt.text(v, w, "left")
	just.sameline()
	just.indent(-30)
	gyatt.text(label, w, "right")
end

function ViewConfig:scoringStats(view)
	local w, h = Layout:move("scoringStats")

	Theme:panel(w, h)

	local scoreItem = view.game.selectModel.scoreItem
	local show = showLoadedScore(view)

	if not scoreItem then
		return
	end

	local play_context = view.game.playContext
	local configs = view.game.configModel.configs
	local judge_name = configs.select.judgements
	local judge = view.judgements[judge_name]
	local counter_names = judge:getOrderedCounterNames()

	local const = show and play_context.const or scoreItem.const
	local scrollSpeed = "X"
	if const then
		scrollSpeed = "Const"
	end

	local pauses = play_context.pauses or 0
	local grade = getGrade(judge_name, judge.accuracy)

	local timings = play_context.timings

	local judge_timings = timings
	if judge.getTimings then
		judge_timings = judge:getTimings()
	end

	local hit = timings.ShortNote.hit
	local miss = timings.ShortNote.miss
	local release_multiplier = judge_timings.LongNoteEnd.hit[1] / judge_timings.ShortNote.hit[1]
	local nearest = timings.nearest

	-- ACCURACY
	w, h = Layout:move("accuracy")
	gfx.setFont(font.accuracy)
	gfx.setColor(Color.text)
	gyatt.frame(judge_name, 10, -4, w, h, "left", "center")
	gyatt.frame(("%0.02f%%"):format(judge.accuracy * 100), -10, -4, w, h, "right", "center")

	gfx.setColor(Color.border)
	gfx.rectangle("fill", 0, h - 4, w, 4)

	-- JUDGEMENTS
	w, h = Layout:move("judgements")

	local colors = getCounterColors(judge_name)

	gfx.setFont(font.counterName)
	for _, counter in ipairs(counter_names) do
		judgementCount(counter:upper(), colors[counter], w, judge.counters[counter], judge.notes)
	end

	judgementCount("MISS", { 1, 0, 0, 1 }, w, judge.counters["miss"], judge.notes)

	w, h = Layout:move("judgements")
	gfx.setColor(Color.separator)
	gfx.rectangle("fill", 25, h - 4, w - 50, 4)

	-- GRADE AND PAUSES
	w, h = Layout:move("grade")

	gfx.setFont(font.grade)
	gfx.setColor(Color.text)

	GradeKV("Pauses:", pauses, w)
	GradeKV("Grade:", grade, w)
	GradeKV("Scroll speed:", scrollSpeed, w)

	w, h = Layout:move("grade")
	gfx.setColor(Color.border)
	gfx.rectangle("fill", 0, h - 4, w, 4)

	-- TIMINGS
	w, h = Layout:move("timings")
	gfx.setFont(font.timings)
	gfx.setColor(Color.text)

	timingsKV("Hit window", ("%i | %i"):format(math.abs(hit[1]) * 1000, hit[2] * 1000), w)
	timingsKV("Miss window", ("%i | %i"):format(math.abs(miss[1]) * 1000, miss[2] * 1000), w)
	timingsKV("Release multiplier", ("%0.1fx"):format(release_multiplier), w)
	timingsKV("Hit logic", nearest and "Nearest" or "Latest note", w)

	w, h = Layout:move("scoringStats")
	Theme:border(w, h)
end

function ViewConfig:draw(view)
	just.origin()

	title(view)
	self:modifiers(view)
	self:scoringStats(view)

	--self.panels()
	--HitGraph(view)

	--self:judgements(view)
	--self:scores(view)
	--self:difficulty(view)
	--self:scoreInfo(view)
	--self:pauses(view)

	--borders()
end

return ViewConfig
