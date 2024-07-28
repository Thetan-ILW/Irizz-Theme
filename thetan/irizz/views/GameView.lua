local class = require("class")
local ScreenTransition = require("thetan.irizz.views.ScreenTransition")
local FrameTimeView = require("sphere.views.FrameTimeView")
local AsyncTasksView = require("sphere.views.AsyncTasksView")
local TextTooltipImView = require("sphere.imviews.TextTooltipImView")
local ContextMenuImView = require("sphere.imviews.ContextMenuImView")
local NotificationView = require("thetan.irizz.views.NotificationView")
local InputMap = require("thetan.irizz.views.GameViewInputMap")
local Theme = require("thetan.irizz.views.Theme")

---@class sphere.GameView
---@operator call: sphere.GameView
---@field view irizz.ScreenView?
---@field actionModel irizz.ActionModel
---@field notificationView irizz.NotificationView
---@field inputMap gyatt.InputMap
local GameView = class()

local last_resize_time = math.huge

---@param game sphere.GameController
function GameView:new(game)
	self.game = game
	self.screenTransition = ScreenTransition()
	self.frameTimeView = FrameTimeView()
end

function GameView:load()
	self.frameTimeView.game = self.game
	self.frameTimeView:load()

	self.actionModel = self.game.actionModel
	self.notificationView = NotificationView()
	self:setView(self.game.selectView)

	self.inputMap = InputMap(self, self.actionModel)
end

function GameView:getViewName()
	return self.viewName
end

---@param view irizz.ScreenView
function GameView:_setView(view)
	if self.view then
		self.view:unload()
	end

	view.prevView = self.view
	self.view = view
	self.view.actionModel = self.actionModel
	self.view.assetModel = self.game.assetModel
	self.view.notificationView = self.notificationView
	self.view:load()

	local viewNames = {
		[self.game.selectView] = "select",
		[self.game.resultView] = "result",
		[self.game.gameplayView] = "gameplay",
		[self.game.multiplayerView] = "multiplayer",
		[self.game.editorView] = "editor",
	}

	self.viewName = viewNames[view]
end

---@param view irizz.ScreenView
function GameView:setView(view)
	---@type table
	local config = self.game.configModel.configs.irizz

	---@type string
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

	if love.timer.getTime() > last_resize_time + 0.15 then
		self.view:resolutionUpdated()
		last_resize_time = math.huge
	end

	self.view:update(dt)
end

function GameView:draw()
	if not self.view then
		return
	end

	self.screenTransition:drawBefore()
	self.view:draw()

	if self.contextMenu and ContextMenuImView(self.contextMenuWidth) then
		if ContextMenuImView(self.contextMenu()) then
			self.contextMenu = nil
		end
	end

	if self.tooltip then
		TextTooltipImView(self.tooltip)
		self.tooltip = nil
	end

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
		self.actionModel.inputChanged(event)
	end

	if event.name == "keypressed" then
		if not event[3] then -- do not repeat
			self.actionModel.keyPressed(event)

			if self:getViewName() ~= "gameplay" then
				self.inputMap:call("global")
			end
		end
	end

	if event.name == "focus" then
		self.actionModel.resetInputs()
	end

	if event.name == "resize" then
		last_resize_time = love.timer.getTime()
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

return GameView
