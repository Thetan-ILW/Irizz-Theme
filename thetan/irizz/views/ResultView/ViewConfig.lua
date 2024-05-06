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
local HitGraph = require("thetan.irizz.views.ResultView.HitGraph")
local Scoring = require("thetan.irizz.views.ResultView.Scoring")

local ScoreListView = require("thetan.irizz.views.ScoreListView")

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

local playContext
local timings

local judge
local judgeName = ""
local scoreSystemName = ""
local counterNames

local customConfig = nil

local gfx = love.graphics

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

function ViewConfig:new(game, custom_config)
	self.scoreListView = ScoreListView(game, true)
	self.scoreListView.rows = 5
	font = Theme:getFonts("resultView")

	if custom_config then
		customConfig = custom_config()
		customConfig:load(game, self)
	end

	HitGraph.showLoadedScore = showLoadedScore
end

function ViewConfig:unload() end

function ViewConfig:loadScore(view)
	local chartview = view.game.selectModel.chartview
	local chartdiff = view.game.playContext.chartdiff
	local scoreItem = view.game.selectModel.scoreItem

	local diff_column = view.game.configModel.configs.settings.select.diff_column
	local time_rate = view.game.playContext.rate
	timeRateFormatted = Text.timeRate:format(time_rate)

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

	local scoreSystems = view.game.rhythmModel.scoreEngine.scoreSystem
	local configs = view.game.configModel.configs
	judgeName = view.currentJudgeName
	judge = scoreSystems.judgements[judgeName]
	scoreSystemName = judge.scoreSystemName
	counterNames = judge.orderedCounters
	playContext = view.game.playContext
	timings = playContext.timings

	local earlyNoteMiss = math.abs(timings.ShortNote.miss[1])
	local lateNoteMiss = timings.ShortNote.miss[2]
	local earlyReleaseMiss = math.abs(timings.LongNoteEnd.miss[1])
	local lateReleaseMiss = timings.LongNoteEnd.miss[2]

	HitGraph.maxEarlyTiming = math.max(earlyNoteMiss, earlyReleaseMiss)
	HitGraph.maxLateTiming = math.max(lateNoteMiss, lateReleaseMiss)
	HitGraph.judge = judge
	HitGraph.counterNames = counterNames
	HitGraph.scoreSystemName = scoreSystemName
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

	color[4] = 1

	gfx.push()
	gfx.setColor(Color.text)
	gfx.translate(10, 4)
	Theme:textWithShadow(label, w, label_height, "left", "center")
	gfx.translate(-20, 0)
	Theme:textWithShadow(count, w, label_height, "right", "center")
	gfx.pop()

	gfx.translate(0, label_height + 8)
end

---@param view table
local function hitGraph(view)
	local w, h = Layout:move("hitGraph")
	Theme:panel(w, h)

	HitGraph.hitGraph.game = view.game
	HitGraph.hitGraph:draw(w, h)
	HitGraph.earlyHitGraph.game = view.game
	HitGraph.earlyHitGraph:draw(w, h)
	HitGraph.missGraph.game = view.game
	HitGraph.missGraph:draw(w, h)

	gfx.setColor(Color.panel)
	gfx.rectangle("fill", -2, h / 2, w + 2, 4)

	Theme:border(w, h)
end

local function GradeKV(label, v, w)
	just.indent(50)
	gyatt.text(label, w, "left")
	just.sameline()
	just.indent(-100)
	gyatt.text(v, w, "right")
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

	local const = show and playContext.const or scoreItem.const
	local scrollSpeed = "X"
	if const then
		scrollSpeed = "Const"
	end

	local pauses = playContext.pauses or 0
	local grade = Scoring.getGrade(scoreSystemName, judge.accuracy)
	local gradeColor = Scoring.gradeColors[scoreSystemName][grade]

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
	gyatt.frame(judgeName, 10, -4, w, h, "left", "center")

	gfx.setColor(gradeColor)
	gyatt.frame(("%0.02f%%"):format((judge.accuracy or 0) * 100), -10, -4, w, h, "right", "center")

	gfx.setColor(Color.border)
	gfx.rectangle("fill", 0, h - 4, w, 4)

	-- JUDGEMENTS
	w, h = Layout:move("judgements")

	local colors = Scoring.counterColors[scoreSystemName]

	gfx.setFont(font.counterName)
	for _, counter in ipairs(counterNames) do
		judgementCount(counter:upper(), colors[counter], w, judge.counters[counter], judge.notes)
	end

	judgementCount("MISS", { 1, 0, 0, 1 }, w, judge.counters["miss"], judge.notes)

	w, h = Layout:move("judgements")
	gfx.setColor(Color.separator)
	gfx.rectangle("fill", 25, h - 4, w - 50, 4)

	-- GRADE AND PAUSES
	w, h = Layout:move("grade")
	gfx.translate(0, 4)

	gfx.setFont(font.grade)
	gfx.setColor(Color.text)

	GradeKV(Text.pauses, pauses, w)

	just.indent(50)
	gyatt.text(Text.grade, w, "left")
	just.sameline()
	just.indent(-100)
	gfx.setColor(gradeColor)
	gyatt.text(grade, w, "right")

	gfx.setColor(Color.text)
	GradeKV(Text.scrollSpeed, scrollSpeed, w)

	w, h = Layout:move("grade")
	gfx.setColor(Color.border)
	gfx.rectangle("fill", 0, h - 4, w, 4)

	-- TIMINGS
	w, h = Layout:move("timings")
	gfx.translate(0, 4)
	gfx.setFont(font.timings)
	gfx.setColor(Color.text)

	timingsKV(Text.hitWindow, ("%i | %i"):format(math.abs(hit[1]) * 1000, hit[2] * 1000), w)
	timingsKV(Text.missWindow, ("%i | %i"):format(math.abs(miss[1]) * 1000, miss[2] * 1000), w)
	timingsKV(Text.releaseMultiplier, ("%0.1fx"):format(release_multiplier), w)
	timingsKV(Text.hitLogic, nearest and Text.nearest or Text.earliestNote, w)

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
	gfx.translate(0, 4)
	gfx.setFont(font.scoreInfo)
	gfx.setColor(Color.text)
	GradeKV(Text.mode, inputMode, w)
	GradeKV(Text.score, scoreFormatted, w)
	GradeKV(Text.accuracy, accuracyFormatted, w)
	GradeKV(Text.rating, ratingFormatted, w)

	gfx.translate(0, 10)
	gfx.setColor(Color.separator)
	gfx.rectangle("fill", 25, 0, w - 50, 4)
	gfx.translate(0, 10)

	gfx.setColor(Color.text)
	gfx.translate(0, 4)
	GradeKV(Text.mean, meanFormatted, w)
	GradeKV(Text.maxError, maxErrorFormatted, w)

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

	if customConfig then
		customConfig:drawUnderPanels()
	end

	title(view)
	self:modifiers(view)
	self:scoringStats(view)
	hitGraph(view)
	self:scoreInfo()
	self:difficulty()
	self:scores(view)

	if customConfig then
		love.graphics.origin()
		customConfig:draw()
	end
end

return ViewConfig
