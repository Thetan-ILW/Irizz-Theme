local class = require("class")
local ScreenTransition = require("thetan.irizz.views.ScreenTransition")
local FrameTimeView = require("sphere.views.FrameTimeView")
local AsyncTasksView = require("sphere.views.AsyncTasksView")
local TextTooltipImView = require("sphere.imviews.TextTooltipImView")
local ContextMenuImView = require("sphere.imviews.ContextMenuImView")
local NotificationView = require("thetan.irizz.views.NotificationView")
local InputMap = require("thetan.irizz.views.GameViewInputMap")

local get_irizz_assets = require("thetan.irizz.assets_loader")

---@class skidibi.GameView
---@operator call: skidibi.GameView
---@field view skibidi.ScreenView?
---@field actionModel skibidi.ActionModel
---@field notificationView irizz.NotificationView
---@field inputMap gyatt.InputMap
local GameView = class()

local last_height_check = -math.huge
local prev_window_res = 0

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
	self.notificationView = NotificationView(get_irizz_assets(self.game))
	prev_window_res = love.graphics.getWidth() * love.graphics.getHeight()
	self:setView(self.game.ui.osuMainMenuView)

	self.inputMap = InputMap(self, self.actionModel)
end

function GameView:getViewName()
	return self.viewName
end

---@param view skibidi.ScreenView
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
		--[self.game.multiplayerView] = "multiplayer",
		[self.game.editorView] = "editor",
	}

	self.viewName = viewNames[view]
end

---@param view skibidi.ScreenView
function GameView:setView(view)
	---@type table
	local config = self.game.configModel.configs.irizz

	---@type string
	local transition = config.transitionAnimation
	view.gameView = self

	self.screenTransition:transit(function()
		if self.view then
			self.view.changingScreen = true
		end

		self.screenTransition:transitAsync(1, 0, transition)
		view.changingScreen = false
		self:_setView(view)
		self.screenTransition:transitAsync(0, 1, transition)
	end)
end

function GameView:reloadView()
	self:setView(self.view)
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

	local time = love.timer.getTime()
	local resolution = love.graphics.getWidth() * love.graphics.getHeight()

	if time > last_height_check + 0.5 then
		if prev_window_res ~= resolution then
			self.view:resolutionUpdated()
			prev_window_res = resolution
		end

		last_height_check = time
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

	self.view:receive(event)
end

---@param f function?
---@param width number?
function GameView:setContextMenu(f, width)
	self.contextMenu = f
	self.contextMenuWidth = width
end

return GameView
