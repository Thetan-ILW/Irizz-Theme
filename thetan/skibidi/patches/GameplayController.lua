local math_util = require("math_util")

local DiffcalcContext = require("sphere.models.DifficultyModel.DiffcalcContext")

local getPP = require("thetan.skibidi.osu_pp")
local has_minacalc, etterna_msd = pcall(require, "libchart.etterna_msd")
local _, minacalc = pcall(require, "libchart.minacalc")

local GameplayController = require("sphere.controllers.GameplayController")

function GameplayController:skip()
	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	self:update(0)

	if not self:hasResult() then
		rhythmModel.audioEngine:unload() -- <<<
	end

	timeEngine:play()
	timeEngine.currentTime = math.huge
	self.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
end

function GameplayController:unload()
	local rhythmModel = self.rhythmModel
	self.loaded = false
	rhythmModel.audioEngine.loaded = false

	self.discordModel:setPresence({})
	self:skip()

	if self:hasResult() then
		self:saveScore()
	end

	rhythmModel:unloadAllEngines(true)
	rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")
	love.mouse.setVisible(true)

	self.windowModel:setVsyncOnSelect(true)

	self.multiplayerModel:setIsPlaying(false)
end

function GameplayController:increasePlaySpeed(delta)
	local speedModel = self.speedModel
	speedModel:increase(delta)

	local gameplay = self.configModel.configs.settings.gameplay
	self.rhythmModel.graphicEngine:setVisualTimeRate(gameplay.speed)

	return speedModel.format[gameplay.speedType]:format(speedModel:get()) -- <<<
end

function GameplayController:increaseLocalOffset(delta)
	local chartview = self.selectModel.chartview

	chartview.offset = chartview.offset or self.offsetModel:getDefaultLocal()
	chartview.offset = math_util.round(chartview.offset + delta, delta)

	self.cacheModel.chartmetasRepo:updateChartmeta({
		id = chartview.chartmeta_id,
		offset = chartview.offset,
	})

	self:updateOffsets()

	return chartview.offset
end

local base_save_score = GameplayController.saveScore

function GameplayController:saveScore()
	base_save_score(self)

	local chartdiff = self.playContext.chartdiff

	local scoreSystem = self.rhythmModel.scoreEngine.scoreSystem
	local osu = scoreSystem.judgements["osu!legacy OD9"]
	local j4 = scoreSystem.judgements["Etterna J4"]
	local pp = getPP(chartdiff.notes_count, chartdiff.osu_diff, 9, osu.score)

	---@type table<string, number>
	local msds = {}

	if has_minacalc and chartdiff.inputmode == "4key" then
		local chart = self.rhythmModel.chart
		local diff_context = DiffcalcContext(chartdiff, chart, chartdiff.rate)

		local notes = diff_context:getSimplifiedNotes()
		local rows, row_count = etterna_msd.getRows(notes)
		local status, result = pcall(minacalc.getSsr, rows, row_count, chartdiff.rate, j4.accuracy)

		if status then
			msds = result
		end
	end

	local key = ("%s_%s"):format(chartdiff.hash, chartdiff.inputmode)

	self.playerProfileModel:addScore(key, {
		time = os.time(),
		mode = chartdiff.inputmode,
		osuAccuracy = osu.accuracy,
		osuPP = pp,
		overall = msds.overall,
		stream = msds.stream,
		jumpstream = msds.jumpstream,
		handstream = msds.handstream,
		stamina = msds.stamina,
		jackspeed = msds.jackspeed,
		chordjack = msds.chordjack,
		technical = msds.technical,
	})
end
