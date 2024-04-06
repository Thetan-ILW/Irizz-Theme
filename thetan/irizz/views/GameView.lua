local class = require("class")
local gyatt = require("thetan.gyatt")
local FadeTransition = require("sphere.views.FadeTransition")
local FrameTimeView = require("sphere.views.FrameTimeView")
local AsyncTasksView = require("sphere.views.AsyncTasksView")
local TextTooltipImView = require("sphere.imviews.TextTooltipImView")
local ContextMenuImView = require("sphere.imviews.ContextMenuImView")
local InputMap = require("thetan.irizz.views.GameViewInputMap")
local Theme = require("thetan.irizz.views.Theme")

---@class sphere.GameView
---@operator call: sphere.GameView
local GameView = class()

---@param game sphere.GameController
function GameView:new(game)
	self.game = game
	self.fadeTransition = FadeTransition()
	self.frameTimeView = FrameTimeView()
end

function GameView:load()
	Theme:init(self.game)

	self.frameTimeView.game = self.game

	self.frameTimeView:load()

	self:setView(self.game.selectView)

	local actionModel = self.game.actionModel
	self.inputMap = InputMap(self, actionModel:getGroup("global"))
end

---@param view sphere.ScreenView
function GameView:_setView(view)
	if self.view then
		self.view:unload()
	end
	view.prevView = self.view
	self.view = view
	self.view:load()

	if self:getViewName() ~= "gameplay" then
		gyatt.vim.enable()
		return
	end

	gyatt.vim.disable()
end

---@param view sphere.ScreenView
function GameView:setView(view)
	view.gameView = self
	self.fadeTransition:transit(function()
		self.fadeTransition:transitAsync(1, 0)
		self:_setView(view)
		self.fadeTransition:transitAsync(0, 1)
	end)
end

function GameView:unload()
	if not self.view then
		return
	end
	self.view:unload()
end

---@param dt number
function GameView:update(dt)
	self.fadeTransition:update()
	if not self.view then
		return
	end
	self.view:update(dt)
end

function GameView:draw()
	if not self.view then
		return
	end
	self.fadeTransition:drawBefore()
	self.view:draw()

	if self.modal then
		self.modal:draw()

		if self.modal.alpha < 0 then
			self.modal = nil
			self.view.modalActive = false
		end
	end

	if self.contextMenu and ContextMenuImView(self.contextMenuWidth) then
		if ContextMenuImView(self.contextMenu()) then
			self.contextMenu = nil
		end
	end
	if self.tooltip then
		TextTooltipImView(self.tooltip)
		self.tooltip = nil
	end

	self.fadeTransition:drawAfter()
	self.frameTimeView:draw()

	local settings = self.game.configModel.configs.settings
	local showTasks = settings.miscellaneous.showTasks

	if showTasks then
		AsyncTasksView()
	end
end

---@param event table
function GameView:receive(event)
	self.frameTimeView:receive(event)
	if not self.view then
		return
	end

	if event.name == "inputchanged" then
		gyatt.inputchanged(event)
	end

	if event.name == "keypressed" then
		gyatt.keypressed(event)

		if self:getViewName() ~= "gameplay" then
			self.inputMap:call("global")
		end
	end

	self.view:receive(event)
end

---@param f function?
---@param width number?
function GameView:setContextMenu(f, width)
	self.contextMenu = f
	self.contextMenuWidth = width
end

---@param modal table
function GameView:setModal(modal)
	local opennedModal = self.modal
	if not opennedModal then
		self.modal = modal
		self.modal.alpha = 0
		self.modal:show()
		self.view.modalActive = true
		return
	end

	if opennedModal.name == modal.name then
		self.modal.shouldClose = true
	end
end

function GameView:closeModal()
	if self.modal then
		self.modal.shouldClose = true
	end
	self.view.modalActive = false
end

function GameView:openModal(modalName)
	local modal = require(modalName)(self.game)
	self:setModal(modal)
end

function GameView:sendQuitSignal()
	if self.modal then
		self.modal:quit()
		return
	end

	if self.view.quit then
		self.view:quit()
	end
end

function GameView:getViewName()
	local t = {
		[self.game.selectView] = "select",
		[self.game.resultView] = "result",
		[self.game.gameplayView] = "gameplay",
		[self.game.multiplayerView] = "multiplayer",
		[self.game.editorView] = "editor",
	}

	return t[self.view]
end

return GameView
