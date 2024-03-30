local modulePatcher = require("ModulePatcher")

modulePatcher:insert("sphere.controllers.GameplayController", "skip", function(_self)
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

modulePatcher:insert("sphere.controllers.GameplayController", "unload", function(_self)
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
