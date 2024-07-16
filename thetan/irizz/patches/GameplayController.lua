local math_util = require("math_util")

local modulePatcher = require("ModulePatcher")

local module = "sphere.controllers.GameplayController"

modulePatcher:insert(module, "skip", function(_self)
	local rhythmModel = _self.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	_self:update(0)

	if not _self:hasResult() then
		rhythmModel.audioEngine:unload()
	end

	timeEngine:play()
	timeEngine.currentTime = math.huge
	_self.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
end)

modulePatcher:insert(module, "unload", function(_self)
	local rhythmModel = _self.rhythmModel
	_self.loaded = false
	rhythmModel.audioEngine.loaded = false

	_self.discordModel:setPresence({})
	_self:skip()

	if _self:hasResult() then
		_self:saveScore()
	end

	rhythmModel:unloadAllEngines(true)
	rhythmModel.inputManager:setMode("external")
	_self.replayModel:setMode("record")
	love.mouse.setVisible(true)

	_self.windowModel:setVsyncOnSelect(true)

	_self.multiplayerModel:setIsPlaying(false)
end)

modulePatcher:insert(module, "increasePlaySpeed", function(self, delta)
	local speedModel = self.speedModel
	speedModel:increase(delta)

	local gameplay = self.configModel.configs.settings.gameplay
	self.rhythmModel.graphicEngine:setVisualTimeRate(gameplay.speed)

	return speedModel.format[gameplay.speedType]:format(speedModel:get())
end)

modulePatcher:insert(module, "increaseLocalOffset", function(self, delta)
	local chartview = self.selectModel.chartview

	chartview.offset = chartview.offset or self.offsetModel:getDefaultLocal()
	chartview.offset = math_util.round(chartview.offset + delta, delta)

	self.cacheModel.chartmetasRepo:updateChartmeta({
		id = chartview.chartmeta_id,
		offset = chartview.offset,
	})

	self:updateOffsets()

	return chartview.offset
end)
