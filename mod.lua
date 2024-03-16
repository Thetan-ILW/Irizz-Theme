local SelectView = require("thetan.irizz.views.SelectView")
local ResultView = require("thetan.irizz.views.ResultView")
local GameView = require("thetan.irizz.views.GameView")
local path_util = require("path_util")

local IrizzTheme = {
	name = "thetan.IrizzTheme",
}

function IrizzTheme:init()
	local modulePatcher = require("ModulePatcher")

	modulePatcher:observe("sphere.controllers.GameController", "load", function(_self, game)
		game.ui.gameView = GameView(game)
		game.gameView = game.ui.gameView

		game.ui.selectView = SelectView()
		game.ui.selectView.game = game
		game.selectView = game.ui.selectView

		game.ui.resultView = ResultView()
		game.ui.resultView.game = game
		game.resultView = game.ui.resultView
	end, self)

	local dirs = require("sphere.persistence.dirs")

	modulePatcher:insert("sphere.persistence.Persistence", "load", function(_self)
		dirs.create()

		local configModel = _self.configModel
		configModel:open("settings", true)
		configModel:open("select", true)
		configModel:open("play", true)
		configModel:open("input", true)
		configModel:open("online", true)
		configModel:open("urls")
		configModel:open("judgements")
		configModel:open("filters")
		configModel:open("files")
		configModel:open("irizz", true)
		configModel:read()

		_self.cacheModel:load()
	end)

	modulePatcher:insert("sphere.controllers.GameplayController", "skip", function(_self)
		local rhythmModel = _self.rhythmModel
		local timeEngine = rhythmModel.timeEngine

		_self:update(0)

		--rhythmModel.audioEngine:unload()
		timeEngine:play()
		timeEngine.currentTime = math.huge
		_self.replayModel:update()
		rhythmModel.logicEngine:update()
		rhythmModel.scoreEngine:update()
	end)

	modulePatcher:insert("sphere.controllers.GameplayController", "unload", function(_self)
		_self.loaded = false

		_self.discordModel:setPresence({})
		_self:skip()

		if _self:hasResult() then
			_self:saveScore()
		end

		local rhythmModel = _self.rhythmModel
		rhythmModel:unloadAllEngines(true)
		rhythmModel.inputManager:setMode("external")
		_self.replayModel:setMode("record")
		love.mouse.setVisible(true)

		_self.windowModel:setVsyncOnSelect(true)

		_self.multiplayerModel:setIsPlaying(false)
	end)

	modulePatcher:insert("sphere.models.RhythmModel", "unloadAllEngines", function(_self, stopAudioEngine)
		if not stopAudioEngine then
			_self.audioEngine:unload()
		end

		_self.logicEngine:unload()
		_self.graphicEngine:unload()

		for _, inputType, inputIndex in _self.noteChart:getInputIterator() do
			_self.observable:send({
				name = "keyreleased",
				virtual = true,
				inputType .. inputIndex
			})
		end
	end)

	modulePatcher:insert("sphere.models.SelectModel", "getAudioPathPreview", function(_self)
		local chartview = _self.chartview
		if not chartview then
			return
		end

		local mode = "absolute"

		local audio_path = chartview.audio_path
		if not audio_path or audio_path == "" then
			return path_util.join(chartview.real_dir, "preview.ogg"), 0, mode
		end

		local full_path = path_util.join(chartview.real_dir, audio_path)
		local preview_time = chartview.preview_time

		if preview_time < 3 and chartview.format == "osu" then
			mode = "relative"
			preview_time = 0.4
		end

		return full_path, preview_time, mode
	end)
end

return IrizzTheme
