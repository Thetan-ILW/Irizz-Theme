local class = require("class")
local gyatt = require("thetan.gyatt")
local just = require("just")

local Layout = love.filesystem.load("thetan/irizz/views/ResultView/OsuLayout.lua")()
local ImageValueView = require("thetan.irizz.views.ResultView.ImageValueView")
local Scoring = require("thetan.irizz.views.ResultView.Scoring")
local HitGraph = require("thetan.irizz.views.ResultView.HitGraph")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textOsuResult
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

local meanFormatted = ""
local maxErrorFormatted = ""
local scrollSpeed = ""
local modsFormatted = ""

local ppFormatted = ""
local username = ""

local gfx = love.graphics

local buttonHoverShader

function OsuViewConfig:new(game, _assets)
	assets = _assets

	if not assets then
		error("\n\nSelect valid osu! skin in the `Settings > UI > osu! result screen` \n\n")
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
		format = "%07d",
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

	buttonHoverShader = gfx.newShader([[
	vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
        {
		vec4 texturecolor = Texel(tex, texture_coords);
		texturecolor.rgb += 0.2;
		return texturecolor * color;
        }
	]])
end

function OsuViewConfig.panels() end

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

function OsuViewConfig:loadScore(view)
	Layout = love.filesystem.load("thetan/irizz/views/ResultView/OsuLayout.lua")()

	local chartview = view.game.selectModel.chartview
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

	local score = judge.score or view.judgements["osu!mania OD9"].score or 0
	scoreValue.value = score

	local base = view.game.rhythmModel.scoreEngine.scoreSystem["base"]

	comboValue.value = base.maxCombo

	timeRate = view.game.playContext.rate

	timeFormatted = os.date("%c", view.game.selectModel.scoreItem.time)
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
	local od = view.currentJudge

	if scoreSystemName ~= "osuMania" then
		grade = Scoring.convertGradeToOsu(grade)
		od = 9
	end

	ppFormatted = ("%i PP"):format(Theme.getPP(judge.notes, chartview.osu_diff, od, score))

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

	local show = showLoadedScore(view)

	local scoreItem = view.game.selectModel.scoreItem
	local rhythmModel = view.game.rhythmModel
	local scoreEngine = rhythmModel.scoreEngine
	local normalscore = rhythmModel.scoreEngine.scoreSystem.normalscore
	local mean = show and normalscore.normalscore.mean or scoreItem.mean

	meanFormatted = ("%i ms"):format(mean * 1000)
	maxErrorFormatted = ("%i ms"):format(scoreEngine.scoreSystem.misc.maxDeltaTime * 1000)

	local const = show and playContext.const or scoreItem.const
	scrollSpeed = "X"
	if const then
		scrollSpeed = "Const"
	end

	local selectModel = view.game.selectModel
	local modifiers = view.game.playContext.modifiers
	if not showLoadedScore(view) and selectModel.scoreItem then
		modifiers = selectModel.scoreItem.modifiers
	end

	modsFormatted = Theme:getModifierString(modifiers)
	username = view.game.configModel.configs.online.user.name or Text.guest
end

function OsuViewConfig:title(view)
	local w, h = Layout:move("title")

	gfx.setColor({ 0, 0, 0, 0.65 })
	gfx.rectangle("fill", 0, 0, w, h)

	gfx.setColor({ 1, 1, 1, 1 })

	if assets.title then
		w, h = Layout:move("titleImage")
		local iw, ih = assets.title:getDimensions()
		gfx.draw(assets.title, w - iw, 0)
	end

	w, h = Layout:move("title")

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

	local second_row = Text.chartFrom:format(setDirectory)

	if chartview.format ~= "sm" then
		second_row = Text.chartBy:format(creator)
	end

	local playInfo = Text.playedBy:format(username, timeFormatted)

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
	if value then
		local w, h = Layout:move(box)
		gfx.translate(w / 2, h / 2)
		value:draw()
		gfx.translate(-w / 2, -h / 2)
	end
end

local function frame(value, box, box2)
	if value then
		local w, h = Layout:move(box, box2)
		gfx.translate(0, h / 2)
		value:draw()
		gfx.translate(0, -h / 2)
	end
end

local function judgeFrame(image, box, box2)
	if image then
		local s = 0.51
		local w, h = Layout:move(box, box2)
		local iw, ih = image:getDimensions()
		gfx.draw(image, (w / 2) - ((iw * s) / 2), (h / 2) - ((ih * s) / 2) + 2, 0, s, s)
	end
end

function OsuViewConfig:panel()
	local w, h = Layout:move("panel")

	gfx.setColor({ 1, 1, 1, 1 })

	if assets.panel then
		gfx.draw(assets.panel, 0, 0, 0)
	end

	centerFrame(scoreValue, "score")

	frame(perfectValue, "column2", "row1")
	frame(marvelousValue, "column4", "row1")
	frame(greatValue, "column2", "row2")
	frame(goodValue, "column4", "row2")
	frame(badValue, "column2", "row3")
	frame(missValue, "column4", "row3")

	judgeFrame(assets.judge.marvelous, "column3", "row1")
	judgeFrame(assets.judge.perfect, "column1", "row1")
	judgeFrame(assets.judge.great, "column1", "row2")
	judgeFrame(assets.judge.good, "column3", "row2")
	judgeFrame(assets.judge.bad, "column1", "row3")
	judgeFrame(assets.judge.miss, "column3", "row3")

	frame(comboValue, "combo")
	frame(accuracyValue, "accuracy")

	Layout:move("comboText")
	gfx.draw(assets.maxCombo)
	Layout:move("accuracyText")
	gfx.draw(assets.accuracy)

	w, h = Layout:move("accuracy")
	gfx.scale(768 / 1080)
	gfx.setFont(font.accuracy)
	gyatt.frame(judgeName, 0 + assets.accuracyNameX, -20 + assets.accuracyNameY, w + 40, h, "center", "top")
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

local function rightSideButtons(view)
	local w, h = Layout:move("base", "watch")

	if assets.replay then
		local iw, ih = assets.replay:getDimensions()
		gfx.translate(w - iw, 0)

		local changed, _, hovered = just.button("replayButton", just.is_over(iw, ih))

		if not hovered then
			gfx.setColor(1, 1, 1, 0.7)
		end

		if changed then
			view:play("replay")
		end

		gfx.draw(assets.replay, 0, 0)
		gfx.setColor(1, 1, 1, 1)
	end
end

local function graphInfo()
	local mx, my = gfx.inverseTransformPoint(love.mouse.getPosition())
	gfx.translate(mx, my)
	gfx.setColor(0, 0, 0, 0.8)
	gfx.rectangle("fill", 0, 0, 250, 120, 4, 4)

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.setFont(font.graphInfo)

	gfx.translate(5, 5)
	just.text(Text.mean:format(meanFormatted))
	just.text(Text.maxError:format(maxErrorFormatted))
	just.text(Text.scrollSpeed:format(scrollSpeed))
	just.text(Text.mods:format(modsFormatted))
end

---@param view table
local function hitGraph(view)
	local w, h = Layout:move("hitGraph")

	gfx.translate(0, 4)
	gfx.setColor({ 1, 1, 1, 1 })

	if assets.graph then
		gfx.draw(assets.graph)
	end

	if hpGraph then
		h = h * 0.86
		gfx.translate(2, 6)
		HitGraph.hpGraph.game = view.game
		HitGraph.hpGraph:draw(w, h)
	else
		h = h * 0.9
		HitGraph.hitGraph.game = view.game
		HitGraph.hitGraph:draw(w, h)
		HitGraph.earlyHitGraph.game = view.game
		HitGraph.earlyHitGraph:draw(w, h)
		HitGraph.missGraph.game = view.game
		HitGraph.missGraph:draw(w, h)

		gfx.setColor(Color.panel)
		gfx.rectangle("fill", -2, h / 2, w + 2, 4)
	end

	if just.is_over(w, h) then
		graphInfo()
	end
end

local function backButton(view)
	local w, h = Layout:move("base")

	if assets.menuBack then
		local iw, ih = assets.menuBack:getDimensions()

		gfx.translate(0, h - ih)
		local changed, _, hovered = just.button("backButton", just.is_over(iw, ih))

		local prev_shader = gfx.getShader()

		if hovered then
			gfx.setShader(buttonHoverShader)
		end

		gfx.draw(assets.menuBack, 0, 0)
		gfx.setShader(prev_shader)

		if changed then
			view:quit()
		end
	end
end

function OsuViewConfig:draw(view)
	Layout:draw()

	self:panel()
	self:title(view)
	self:grade()
	rightSideButtons(view)
	backButton(view)

	hitGraph(view)

	local configs = view.game.configModel.configs
	local irizz = configs.irizz

	if not irizz.showPP then
		return
	end

	local w, h = Layout:move("base")
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.setFont(font.pp)
	gyatt.frame(ppFormatted, -20, 0, w, h, "right", "bottom")
end

return OsuViewConfig
