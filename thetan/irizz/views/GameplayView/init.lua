local Layout = require("sphere.views.GameplayView.Layout")
local Background = require("sphere.views.GameplayView.Background")
local Foreground = require("sphere.views.GameplayView.Foreground")
local OsuPauseScreen = require("thetan.irizz.views.GameplayView.OsuPauseScreen")
local PauseScreen = require("thetan.irizz.views.GameplayView.PauseScreen")
local ScreenView = require("sphere.views.ScreenView")
local SequenceView = require("sphere.views.SequenceView")
local just = require("just")
local time_util = require("time_util")

---@class sphere.GameplayView: sphere.ScreenView
---@operator call: sphere.GameplayView
local GameplayView = ScreenView + {}

---@param game sphere.GameController
function GameplayView:new(game)
	self.game = game
	self.sequenceView = SequenceView()
end

function GameplayView:load()
	self.game.rhythmModel.observable:add(self.sequenceView)
	self.game.gameplayController:load()

	self.subscreen = ""
	self.failed = false

	local sequence_view = self.sequenceView

	local note_skin = self.game.noteSkinModel.noteSkin

	sequence_view.game = self.game
	sequence_view.subscreen = "gameplay"
	sequence_view:setSequenceConfig(note_skin.playField)
	sequence_view:load()

	local chartview = self.game.selectModel.chartview

	local length = time_util.format((chartview.duration or 0) / self.game.playContext.rate)
	local values = { chartview.artist, chartview.title, chartview.name, length }
	self.game.gameView.showMessage("chartStarted", values, { show_time = 2, small_text = true })

	local note_skin_pause = note_skin.pauseScreen

	if note_skin_pause and note_skin_pause.type == "osu" then
		self.pauseScreen = OsuPauseScreen(note_skin_pause)
	elseif note_skin_pause and note_skin_pause.instance then
		self.pauseScreen = note_skin_pause.instance
	else
		self.pauseScreen = PauseScreen()
	end
end

function GameplayView:unload()
	self.pauseScreen:unload()
	self.game.gameplayController:unload()
	self.game.rhythmModel.observable:remove(self.sequenceView)
	self.sequenceView:unload()
end

function GameplayView:retry()
	self.game.gameplayController:retry()
	self.sequenceView:unload()
	self.sequenceView:load()
end

function GameplayView:draw()
	just.container("screen container", true)
	self:keypressed()
	self:keyreleased()

	Layout:draw()
	Background(self)
	self.sequenceView:draw()
	if self.subscreen == "pause" then
		self.pauseScreen:draw(self)
	end
	Foreground(self)
	just.container()

	local state = self.game.pauseModel.state
	local multiplayerModel = self.game.multiplayerModel
	local isPlaying = multiplayerModel.room and multiplayerModel.isPlaying
	if
		not love.window.hasFocus()
		and state ~= "pause"
		and not self.game.rhythmModel.logicEngine.autoplay
		and not isPlaying
		and self.game.rhythmModel.inputManager.mode ~= "internal"
	then
		self.game.gameplayController:pause()
		self.pauseScreen:show()
	end
end

---@param dt number
function GameplayView:update(dt)
	self.game.gameplayController:update(dt)

	local state = self.game.pauseModel.state
	if state == "play" then
		self.subscreen = ""
	elseif state == "pause" then
		self.subscreen = "pause"
	end

	if self.game.pauseModel.needRetry then
		self.failed = false
		self:retry()
	end

	local timeEngine = self.game.rhythmModel.timeEngine
	if timeEngine.currentTime >= timeEngine.maxTime + 1 then
		self:quit()
	end

	local actionOnFail = self.game.configModel.configs.settings.gameplay.actionOnFail
	local failed = self.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed()
	if failed and not self.failed then
		if actionOnFail == "pause" then
			self.game.gameplayController:changePlayState("pause")
			self.failed = true
		elseif actionOnFail == "quit" then
			self:quit()
		end
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		self:quit()
	end

	self.sequenceView:update(dt)
end

---@param event table
function GameplayView:receive(event)
	self.game.gameplayController:receive(event)
	self.sequenceView:receive(event)
end

function GameplayView:quit()
	if self.game.gameplayController:hasResult() then
		self:changeScreen("resultView")
	elseif self.game.multiplayerModel.room then
		self:changeScreen("multiplayerView")
	else
		self:changeScreen("selectView")
	end
end

function GameplayView:keypressed()
	local input = self.game.configModel.configs.settings.input
	local gameplayController = self.game.gameplayController

	local kp = just.keypressed
	if kp(input.skipIntro) then
		gameplayController:skipIntro()
	elseif kp(input.offset.decrease) then
		gameplayController:increaseLocalOffset(-0.001)
	elseif kp(input.offset.increase) then
		gameplayController:increaseLocalOffset(0.001)
	elseif kp(input.offset.reset) then
		gameplayController:resetLocalOffset()
	elseif kp(input.playSpeed.decrease) then
		gameplayController:increasePlaySpeed(-1)
	elseif kp(input.playSpeed.increase) then
		gameplayController:increasePlaySpeed(1)
	end

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local state = self.game.pauseModel.state
	if state == "play" then
		if kp(input.pause) and not shift then
			gameplayController:changePlayState("pause")
			self.pauseScreen:show()
		elseif kp(input.pause) and shift then
			self:quit()
		elseif kp(input.quickRestart) then
			gameplayController:changePlayState("retry")
		end
	elseif state == "pause" then
		if kp(input.pause) and not shift then
			gameplayController:changePlayState("play")
			self.pauseScreen:hide()
		elseif kp(input.pause) and shift then
			self:quit()
		elseif kp(input.quickRestart) then
			gameplayController:changePlayState("retry")
		end
	elseif state == "pause-play" and kp(input.pause) then
		gameplayController:changePlayState("pause")
		self.pauseScreen:show()
	end
end

function GameplayView:keyreleased()
	local state = self.game.pauseModel.state
	local input = self.game.configModel.configs.settings.input
	local gameplayController = self.game.gameplayController

	local kr = just.keyreleased
	if state == "play-pause" and kr(input.pause) then
		gameplayController:changePlayState("play")
	elseif state == "pause-retry" and kr(input.quickRestart) then
		gameplayController:changePlayState("pause")
	elseif state == "play-retry" and kr(input.quickRestart) then
		gameplayController:changePlayState("play")
	end
end

return GameplayView
