local class = require("class")
local gyatt = require("thetan.gyatt")
local ScreenTransition = require("thetan.irizz.views.ScreenTransition")
local FrameTimeView = require("sphere.views.FrameTimeView")
local AsyncTasksView = require("sphere.views.AsyncTasksView")
local TextTooltipImView = require("sphere.imviews.TextTooltipImView")
local ContextMenuImView = require("sphere.imviews.ContextMenuImView")
local MainMenuView = require("thetan.irizz.views.MainMenuView")
local NotificationView = require("thetan.irizz.views.NotificationView")
local InputMap = require("thetan.irizz.views.GameViewInputMap")
local Theme = require("thetan.irizz.views.Theme")

---@class sphere.GameView
---@operator call: sphere.GameView
local GameView = class()

---@param game sphere.GameController
function GameView:new(game)
	self.game = game
	self.screenTransition = ScreenTransition()
	self.frameTimeView = FrameTimeView()
end

function GameView:load()
	Theme:init(self.game)

	self.frameTimeView.game = self.game

	self.frameTimeView:load()

	self:setView(self.game.selectView)

	self.actionModel = self.game.actionModel
	self.inputMap = InputMap(self, self.actionModel)

	self.mainMenuView = MainMenuView(self)
	NotificationView:init()
end

function GameView:getViewName()
	return self.viewName
end

---@param view sphere.ScreenView
function GameView:_setView(view)
	if self.view then
		self.view:unload()
	end

	view.prevView = self.view
	self.view = view
	self.view:load()

	local viewNames = {
		[self.game.selectView] = "select",
		[self.game.resultView] = "result",
		[self.game.gameplayView] = "gameplay",
		[self.game.multiplayerView] = "multiplayer",
		[self.game.editorView] = "editor",
	}

	self.viewName = viewNames[view]

	if self.viewName ~= "gameplay" then
		--gyatt.vim.enable()
		return
	end

	gyatt.vim.disable()
end

---@param view sphere.ScreenView
function GameView:setView(view)
	local config = self.game.configModel.configs.irizz
	local transition = config.transitionAnimation
	view.gameView = self
	self.screenTransition:transit(function()
		self.screenTransition:transitAsync(1, 0, transition)
		self:_setView(view)
		self.screenTransition:transitAsync(0, 1, transition)
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
	self.screenTransition:update()
	if not self.view then
		return
	end
	self.view:update(dt)
end

function GameView:draw()
	if not self.view then
		return
	end

	self.screenTransition:drawBefore()
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

	self.mainMenuView:draw(self:getViewName(), self.view)
	NotificationView:draw()

	self.screenTransition:drawAfter()
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
		--gyatt.inputchanged(event)
	end

	if event.name == "keypressed" then
		self.actionModel.keyPressed(event)

		if self:getViewName() ~= "gameplay" then
			self.inputMap:call("global")
		end
	end

	if event.name == "focus" then
		self.actionModel.resetInputs()
	end

	self.view:receive(event)
end

---@param f function?
---@param width number?
function GameView:setContextMenu(f, width)
	self.contextMenu = f
	self.contextMenuWidth = width
end

function GameView.showMessage(...)
	NotificationView:show(...)
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

	if self.mainMenuView:isActive() then
		self.mainMenuView:toggle()
		return
	end

	if self.view.quit then
		self.view:quit()
	end
end

return GameView
