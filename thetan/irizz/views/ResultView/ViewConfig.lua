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
local timeRateFormatted = ""
local inputMode = ""
local accuracyFormatted = ""
local scoreFormatted = ""
local meanFormatted = ""
local maxErrorFormatted = ""
local ratingFormatted = ""

local gfx = love.graphics

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

function ViewConfig:loadScore(view)
	local chartview = view.game.selectModel.chartview
	local chartdiff = view.game.playContext.chartdiff
	local scoreItem = view.game.selectModel.scoreItem

	local diff_column = view.game.configModel.configs.settings.select.diff_column
	local time_rate = view.game.playContext.rate
	timeRateFormatted = ("Time rate: %0.02fx"):format(time_rate)

	difficulty = (chartview.difficulty or 0) * time_rate
	patterns = chartview.level and "Lv." .. chartview.level or Text.noPatterns

	if diff_column == "msd_diff" and chartdiff.msd_diff_data then
		difficulty = chartdiff.msd_diff
		patterns = Theme.getMaxAndSecondFromSsr(chartdiff.msd_diff_data):upper() or Text.noPatterns
	end

	difficultyColor = Theme:getDifficultyColor(difficulty, diff_column)
	calculator = Theme.formatDiffColumns(diff_column)

	local show = showLoadedScore(view)

	local ratingHitTimingWindow = view.game.configModel.configs.settings.gameplay.ratingHitTimingWindow

	local rhythmModel = view.game.rhythmModel
	local normalscore = rhythmModel.scoreEngine.scoreSystem.normalscore
	local scoreEngine = rhythmModel.scoreEngine

	local _inputMode = show and tostring(rhythmModel.noteChart.inputMode) or scoreItem.inputmode
	inputMode = Format.inputMode(_inputMode)

	local score = not show and scoreItem.score
		or erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2))) * 10000
	if score ~= score then
		score = 0
	end

	scoreFormatted = ("%i"):format(score)

	local accuracyValue = show and normalscore.accuracyAdjusted or scoreItem.accuracy
	accuracyFormatted = Format.accuracy(accuracyValue)

	local mean = show and normalscore.normalscore.mean or scoreItem.mean

	meanFormatted = ("%i ms"):format(mean * 1000)
	maxErrorFormatted = ("%i ms"):format(scoreEngine.scoreSystem.misc.maxDeltaTime * 1000)
	ratingFormatted = ("%0.02f PR"):format(scoreItem.rating)
end

local boxes = {
	"scoringStats",
	"hitGraph",
	"difficulty",
	"scores",
	"mods",
	"scoreInfo",
}

function ViewConfig.panels()
	for _, name in ipairs(boxes) do
		local w, h = Layout:move(name)
		Theme:panel(w, h)
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
local function hitGraph(view)
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

local gradeColors = {
	soundsphere = {
		["-"] = { 1, 1, 1, 1 },
	},
	osuMania = {
		SS = { 0.6, 0.8, 1, 1 },
		S = { 0.95, 0.796, 0.188, 1 },
		A = { 0.07, 0.8, 0.56, 1 },
		B = { 0.1, 0.39, 1, 1 },
		C = { 0.42, 0.48, 0.51, 1 },
		D = { 0.51, 0.37, 0, 1 },
	},
	etterna = {
		AAAAA = { 1, 1, 1, 1 },
		AAAA = { 0.6, 0.8, 1, 1 },
		AAA = { 0.95, 0.796, 0.188, 1 },
		AA = { 0.07, 0.8, 0.56, 1 },
		B = { 0.1, 0.7, 1, 1 },
		C = { 1, 0.1, 0.7, 1 },
		F = { 0.51, 0.37, 0, 1 },
	},
	quaver = {
		X = { 0.6, 0.8, 1, 1 },
		S = { 0.95, 0.796, 0.188, 1 },
		A = { 0.95, 0.796, 0.188, 1 },
		B = { 0.07, 0.8, 0.56, 1 },
		C = { 0.1, 0.39, 1, 1 },
		D = { 0.42, 0.48, 0.51, 1 },
		F = { 0.51, 0.37, 0, 1 },
	},
}

local function getGradeColor(judge_name, grade)
	if string.find(judge_name, "osu!mania") then
		return gradeColors.osuMania[grade]
	elseif string.find(judge_name, "Etterna") then
		return gradeColors.etterna[grade]
	elseif string.find(judge_name, "Quaver") then
		return gradeColors.quaver[grade]
	elseif string.find(judge_name, "Soundsphere") then
		return gradeColors.soundsphere[grade]
	end
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
	local gradeColor = getGradeColor(judge_name, grade)

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

	gfx.setColor(gradeColor)
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

	just.indent(50)
	gyatt.text("Grade:", w, "left")
	just.sameline()
	just.indent(-100)
	gfx.setColor(gradeColor)
	gyatt.text(grade, w, "right")

	gfx.setColor(Color.text)
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

function ViewConfig:scoreInfo()
	local w, h = Layout:move("scoreInfo")
	Theme:panel(w, h)

	w, h = Layout:move("timeRate")
	gfx.setFont(font.timeRate)
	gfx.setColor(Color.text)

	gyatt.frame(timeRateFormatted, 0, 0, w, h, "center", "center")

	gfx.setColor(Color.separator)
	gfx.rectangle("fill", 25, h - 4, w - 50, 4)
	gfx.translate(0, 10)

	w, h = Layout:move("scoreInfoInner")
	gfx.setFont(font.scoreInfo)
	gfx.setColor(Color.text)
	GradeKV("Mode: ", inputMode, w)
	GradeKV("Score: ", scoreFormatted, w)
	GradeKV("Accuracy: ", accuracyFormatted, w)
	GradeKV("Rating: ", ratingFormatted, w)

	gfx.translate(0, 10)
	gfx.setColor(Color.separator)
	gfx.rectangle("fill", 25, 0, w - 50, 4)
	gfx.translate(0, 10)

	gfx.setColor(Color.text)
	GradeKV("Mean: ", meanFormatted, w)
	GradeKV("Max error: ", maxErrorFormatted, w)

	w, h = Layout:move("scoreInfo")
	Theme:border(w, h)
end

function ViewConfig:difficulty()
	local w, h = Layout:move("difficulty")

	Theme:panel(w, h)

	w, h = Layout:move("difficultyValue")
	gfx.setColor(Color.innerPanel)
	gfx.rectangle("fill", 0, 0, w, h)

	gfx.setColor(difficultyColor)
	gfx.setFont(font.difficultyValue)
	gyatt.frame(("%0.02f"):format(difficulty), 0, -20, w, h, "center", "center")

	gfx.setFont(font.calculator)
	gyatt.frame(calculator, 0, 20, w, h, "center", "center")

	w, h = Layout:move("difficultyPatterns")
	gfx.setColor(Color.text)
	gfx.setFont(font.patterns)
	gyatt.frame(patterns, 0, 0, w, h, "center", "center")

	w, h = Layout:move("difficulty")
	Theme:border(w, h)
end

function ViewConfig:scores(view)
	local w, h = Layout:move("scores")
	Theme:panel(w, h)
	local list = self.scoreListView
	list:draw(w, h, true)
	if list.openResult then
		list.openResult = false
		view:loadScore(list.selectedScoreIndex)
	end

	Theme:border(w, h)
end

function ViewConfig:modifiers(view)
	local w, h = Layout:move("mods")

	Theme:panel(w, h)
	local selectModel = view.game.selectModel
	local modifiers = view.game.playContext.modifiers
	if not showLoadedScore(view) and selectModel.scoreItem then
		modifiers = selectModel.scoreItem.modifiers
	end

	local text = Theme:getModifierString(modifiers)
	gfx.setFont(font.modifiers)
	gfx.setColor(Color.text)
	gyatt.frame(text, 0, 0, w, h, "center", "center")
	Theme:border(w, h)
end

function ViewConfig:draw(view)
	just.origin()

	title(view)
	self:modifiers(view)
	self:scoringStats(view)
	hitGraph(view)
	self:scoreInfo()
	self:difficulty()
	self:scores(view)
end

return ViewConfig
