local class = require("class")
local gyatt = require("thetan.gyatt")

local Layout = love.filesystem.load("thetan/irizz/views/ResultView/OsuLayout.lua")()
local ImageValueView = require("thetan.irizz.views.ResultView.ImageValueView")
local Scoring = require("thetan.irizz.views.ResultView.Scoring")
local HitGraph = require("thetan.irizz.views.ResultView.HitGraph")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local font

local OsuViewConfig = class()

local assets

local judge
local judgeName
local counterNames

local marvelousValue
local perfectValue
local greatValue
local goodValue
local badValue
local missValue

local comboValue
local accuracyValue
local scoreValue

local timeRate = 1
local timeFormatted = ""
local setDirectory = ""
local creator = ""

local grade = ""
local hpGraph = false

local gfx = love.graphics

function OsuViewConfig:new(game, _assets)
	assets = _assets

	if not assets then
		error(
			"\n\nNo skin.ini in the `userdata/ui/result/`. COPY your osu! skin there or switch back to the default result screen.\n\n"
		)
	end

	font = Theme:getFonts("osuResultView")
	local overlap = -assets.scoreOverlap

	marvelousValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	perfectValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	greatValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	goodValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	badValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	missValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	comboValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	accuracyValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "left",
		format = "%0.02f%%",
		multiplier = 100,
		scale = 1.1,
		overlap = overlap,
		files = assets.scoreFont,
	})

	scoreValue = ImageValueView({
		x = 0,
		y = 0,
		oy = 0.5,
		align = "center",
		format = "%i",
		multiplier = 1,
		scale = 1.2,
		overlap = overlap,
		files = assets.scoreFont,
	})

	marvelousValue:load()
	perfectValue:load()
	greatValue:load()
	goodValue:load()
	badValue:load()
	missValue:load()

	comboValue:load()
	accuracyValue:load()
	scoreValue:load()
end

function OsuViewConfig.panels() end

function OsuViewConfig:loadScore(view)
	Layout = love.filesystem.load("thetan/irizz/views/ResultView/OsuLayout.lua")()

	local configs = view.game.configModel.configs
	local irizz = configs.irizz

	judgeName = view.currentJudgeName
	judge = view.judgements[judgeName]
	counterNames = judge:getOrderedCounterNames()

	marvelousValue.value = judge.counters[counterNames[1]]
	perfectValue.value = judge.counters[counterNames[2]]
	missValue.value = judge.counters["miss"]

	if judgeName ~= "Soundsphere" then
		greatValue.value = judge.counters[counterNames[3]]
		goodValue.value = judge.counters[counterNames[4]]
		badValue.value = judge.counters[counterNames[5]]
	end

	accuracyValue.value = judge.accuracy

	scoreValue.value = judge.score or view.judgements["osu!mania OD9"].score

	local base = view.game.rhythmModel.scoreEngine.scoreSystem["base"]

	comboValue.value = base.maxCombo

	timeRate = view.game.playContext.rate

	timeFormatted = os.date("%c", view.game.selectModel.scoreItem.time)
	local chartview = view.game.selectModel.chartview
	setDirectory = chartview.set_dir
	creator = chartview.creator

	local scoreSystemName
	if string.find(judgeName, "osu!mania") then
		scoreSystemName = "osuMania"
	elseif string.find(judgeName, "Etterna") then
		scoreSystemName = "etterna"
	elseif string.find(judgeName, "Quaver") then
		scoreSystemName = "quaver"
	elseif string.find(judgeName, "Soundsphere") then
		scoreSystemName = "soundsphere"
	end

	grade = Scoring.getGrade(scoreSystemName, judge.accuracy)

	if scoreSystemName ~= "osuMania" then
		grade = Scoring.convertGradeToOsu(grade)
	end

	local playContext = view.game.playContext
	local timings = playContext.timings

	local earlyNoteMiss = math.abs(timings.ShortNote.miss[1])
	local lateNoteMiss = timings.ShortNote.miss[2]
	local earlyReleaseMiss = math.abs(timings.LongNoteEnd.miss[1])
	local lateReleaseMiss = timings.LongNoteEnd.miss[2]

	HitGraph.maxEarlyTiming = math.max(earlyNoteMiss, earlyReleaseMiss)
	HitGraph.maxLateTiming = math.max(lateNoteMiss, lateReleaseMiss)
	HitGraph.judge = judge
	HitGraph.counterNames = counterNames
	HitGraph.scoreSystemName = scoreSystemName

	hpGraph = irizz.hpGraph
end

function OsuViewConfig:title(view)
	local w, h = Layout:move("title")

	gfx.setColor({ 0, 0, 0, 0.65 })
	gfx.rectangle("fill", 0, 0, w, h)

	gfx.setColor({ 1, 1, 1, 1 })

	if assets.title then
		gfx.draw(assets.title, 0, 0, 0, 1, 1)
	end

	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	local title = ("%s - %s"):format(chartview.artist, chartview.title)

	if chartview.name and timeRate == 1 then
		title = ("%s [%s]"):format(title, chartview.name)
	elseif chartview.name and timeRate ~= 1 then
		title = ("%s [%s %0.02fx]"):format(title, chartview.name, timeRate)
	else
		title = ("%s [%s %0.02fx]"):format(title, timeRate)
	end

	local second_row = string.format("Chart from %s", setDirectory)

	if chartview.format ~= "sm" then
		second_row = string.format("Chart by %s", creator)
	end

	local playInfo = string.format("Played by Guest on %s", timeFormatted)

	gfx.scale(768 / 1080)
	gfx.setColor(Color.text)
	gfx.setFont(font.title)
	gyatt.frame(title, 9, 0, math.huge, h, "left", "top")

	gfx.setFont(font.creator)
	gyatt.frame(second_row, 9, 65, math.huge, h, "left", "top")

	gfx.setFont(font.playInfo)
	gyatt.frame(playInfo, 9, 95, math.huge, h, "left", "top")
	gfx.scale(1)
end

local function centerFrame(value, box)
	local w, h = Layout:move(box)
	gfx.translate(w / 2, h / 2)
	value:draw()
	gfx.translate(-w / 2, -h / 2)
end

local function frame(value, box, box2)
	local w, h = Layout:move(box, box2)
	gfx.translate(0, h / 2)
	value:draw()
	gfx.translate(0, -h / 2)
end

function OsuViewConfig:panel()
	local w, h = Layout:move("panel")

	gfx.setColor({ 1, 1, 1, 1 })

	gfx.draw(assets.panel, 0, 0, 0)

	centerFrame(scoreValue, "score")

	frame(perfectValue, "column2", "row1")
	frame(marvelousValue, "column4", "row1")
	frame(greatValue, "column2", "row2")
	frame(goodValue, "column4", "row2")
	frame(badValue, "column2", "row3")
	frame(missValue, "column4", "row3")

	frame(comboValue, "combo")
	frame(accuracyValue, "accuracy")

	w, h = Layout:move("accuracy")
	gfx.scale(768 / 1080)
	gfx.setFont(font.accuracy)
	gyatt.frame(judgeName, 0, -20, w + 40, h, "center", "top")
	gfx.scale(1)
end

function OsuViewConfig:grade()
	local image = assets.grade[grade]

	if image then
		Layout:move("grade")
		local iw, ih = image:getDimensions()

		local x = iw / 2
		local y = ih / 2
		gfx.draw(image, -x, -y)
	end
end

---@param view table
local function hitGraph(view)
	local w, h = Layout:move("hitGraph")

	gfx.translate(0, 4)
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(assets.graph)

	if hpGraph then
		HitGraph.hpGraph.game = view.game
		HitGraph.hpGraph:draw(w, h)
		return
	end

	HitGraph.hitGraph.game = view.game
	HitGraph.hitGraph:draw(w, h)
	HitGraph.earlyHitGraph.game = view.game
	HitGraph.earlyHitGraph:draw(w, h)
	HitGraph.missGraph.game = view.game
	HitGraph.missGraph:draw(w, h)

	gfx.setColor(Color.panel)
	gfx.rectangle("fill", -2, h / 2, w + 2, 4)
end

function OsuViewConfig:draw(view)
	Layout:draw()

	self:panel()
	self:title(view)
	self:grade()

	hitGraph(view)
end

return OsuViewConfig
