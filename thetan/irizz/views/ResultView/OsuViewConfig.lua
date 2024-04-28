local class = require("class")
local spherefonts = require("sphere.assets.fonts")
local gyatt = require("thetan.gyatt")

local Layout = love.filesystem.load("thetan/irizz/views/ResultView/OsuLayout.lua")()
local ImageValueView = require("thetan.irizz.views.ResultView.ImageValueView")
local Scoring = require("thetan.irizz.views.ResultView.Scoring")
local HitGraph = require("thetan.irizz.views.ResultView.HitGraph")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local OsuViewConfig = class()

local titleImage
local panelImage

local titleFont
local creatorFont
local playInfoFont
local accuracyFont

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

local timeRate = 1
local timeFormatted = ""
local setDirectory = ""

local grade = ""

local gradeImages = {}

local gfx = love.graphics

local function getFont(config)
	if config.filename then
		config[1], config[2] = config.filename, config.size
	end

	return spherefonts.get(unpack(config))
end

function OsuViewConfig:new(game, config)
	titleImage = gfx.newImage(config.title)
	panelImage = gfx.newImage(config.panel)

	local x1 = 170
	local x2 = 620

	local y1 = 215
	local y2 = 350
	local y3 = 485

	titleFont = getFont(config.titleFont)
	creatorFont = getFont(config.creatorFont)
	playInfoFont = getFont(config.playInfoFont)
	accuracyFont = getFont(config.accuracyFont)

	gradeImages = {
		SS = gfx.newImage(config.gradeSS),
		S = gfx.newImage(config.gradeS),
		A = gfx.newImage(config.gradeA),
		B = gfx.newImage(config.gradeB),
		C = gfx.newImage(config.gradeC),
		D = gfx.newImage(config.gradeD),
	}

	marvelousValue = ImageValueView({
		x = x2,
		y = y1,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.3,
		overlap = 1,
		files = config.scoreFont,
	})

	perfectValue = ImageValueView({
		x = x1,
		y = y1,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.3,
		overlap = 1,
		files = config.scoreFont,
	})

	greatValue = ImageValueView({
		x = x1,
		y = y2,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.3,
		overlap = 1,
		files = config.scoreFont,
	})

	goodValue = ImageValueView({
		x = x2,
		y = y2,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.3,
		overlap = 1,
		files = config.scoreFont,
	})

	badValue = ImageValueView({
		x = x1,
		y = y3,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.3,
		overlap = 1,
		files = config.scoreFont,
	})

	missValue = ImageValueView({
		x = x2,
		y = y3,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.3,
		overlap = 1,
		files = config.scoreFont,
	})

	comboValue = ImageValueView({
		x = 80,
		y = 630,
		oy = 0.5,
		align = "left",
		format = "%ix",
		scale = 1.3,
		overlap = 1,
		files = config.scoreFont,
	})

	accuracyValue = ImageValueView({
		x = 490,
		y = 640,
		oy = 0.5,
		align = "left",
		format = "%0.02f%%",
		multiplier = 100,
		scale = 1.1,
		overlap = 1,
		files = config.scoreFont,
	})

	marvelousValue:load()
	perfectValue:load()
	greatValue:load()
	goodValue:load()
	badValue:load()
	missValue:load()

	comboValue:load()
	accuracyValue:load()
end

function OsuViewConfig.panels() end

function OsuViewConfig:loadScore(view)
	Layout = love.filesystem.load("thetan/irizz/views/ResultView/OsuLayout.lua")()

	local configs = view.game.configModel.configs
	judgeName = configs.select.judgements
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

	local base = view.game.rhythmModel.scoreEngine.scoreSystem["base"]

	comboValue.value = base.maxCombo

	timeRate = view.game.playContext.rate

	timeFormatted = os.date("%c", view.game.selectModel.scoreItem.time)
	local chartview = view.game.selectModel.chartview
	setDirectory = chartview.set_dir

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
end

function OsuViewConfig:title(view)
	local w, h = Layout:move("title")
	local iw, ih = titleImage:getDimensions()

	local scale = 1920 / iw

	gfx.setColor({ 0, 0, 0, 0.65 })
	gfx.rectangle("fill", 0, 0, w, h)

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(titleImage, 0, 0, 0, scale, scale)

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

	local creator = string.format("Chart from %s", setDirectory)
	local playInfo = string.format("Played by Guest on %s", timeFormatted)

	gfx.setColor(Color.text)
	gfx.setFont(titleFont)
	gyatt.frame(title, 9, 9, w, h, "left", "top")

	gfx.setFont(creatorFont)
	gyatt.frame(creator, 9, 65, w, h, "left", "top")

	gfx.setFont(playInfoFont)
	gyatt.frame(playInfo, 9, 95, w, h, "left", "top")
end

function OsuViewConfig:panel()
	local w, h = Layout:move("panel")
	local iw, ih = panelImage:getDimensions()

	local scale = 1

	if iw > 1920 then
		scale = 1920 / iw
	elseif ih > 727 then
		scale = 727 / ih
	end

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(panelImage, 0, 0, 0, scale, scale)

	marvelousValue:draw()
	perfectValue:draw()
	greatValue:draw()
	goodValue:draw()
	badValue:draw()
	missValue:draw()

	comboValue:draw()
	accuracyValue:draw()

	gfx.setFont(accuracyFont)
	gyatt.frame(judgeName, 500, 600, math.huge, math.huge, "left", "top")
end

function OsuViewConfig:grade()
	gfx.origin()

	local image = gradeImages[grade]

	local w, h = gfx.getDimensions()
	local iw, ih = image:getDimensions()

	local scale = h / ih

	gfx.draw(image, w - (iw * scale), -100, 0, scale, scale)
end

---@param view table
local function hitGraph(view)
	local w, h = Layout:move("hitGraph")

	gfx.translate(0, 2)

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
