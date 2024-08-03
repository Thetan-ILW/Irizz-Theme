local math_util = require("math_util")

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

	local score_system = self.rhythmModel.scoreEngine.scoreSystem
	local osu = score_system.judgements["osu!legacy OD9"]

	if self.playContext.scoreEntry.pauses > 0 then
		return
	end

	if osu.accuracy < 0.85 then
		return
	end

	local chartdiff = self.playContext.chartdiff
	local key = ("%s_%s"):format(chartdiff.hash, chartdiff.inputmode)
	local chart = self.rhythmModel.chart

	self.playerProfileModel:addScore(key, chart, chartdiff, score_system)
end
