local ScreenView = require("thetan.skibidi.views.ScreenView")

local gyatt = require("thetan.gyatt")
local ViewConfig = require("thetan.osu.views.MainMenuView.ViewConfig")
local InputMap = require("thetan.osu.views.MainMenuView.InputMap")

local get_assets = require("thetan.osu.views.assets_loader")

---@class osu.MainMenuView : skibidi.ScreenView
---@operator call: osu.MainMenuView
local MainMenuView = ScreenView + {}

local window_height = 0

function MainMenuView:load()
	self.game.selectController:load(self)

	self.assets = get_assets(self.game)
	self.viewConfig = ViewConfig(self.game, self.assets)
	self.inputMap = InputMap(self, self.actionModel)
	self.actionModel.enable()

	window_height = love.graphics.getHeight()
	love.mouse.setVisible(false)

	self.mouseMoveTime = love.timer.getTime()
	self.afkPercent = 0
end

function MainMenuView:beginUnload()
	self.game.selectController:beginUnload()
end

function MainMenuView:unload()
	self.game.selectController:unload()
end

---@param dt number
function MainMenuView:update(dt)
	ScreenView.update(self, dt)
	self.game.selectController:update()

	local fade_out = 1 - gyatt.easeOutCubic(self.mouseMoveTime + 7, 1)
	self.afkPercent = fade_out
	self.viewConfig.hasFocus = self.modal == nil
end

function MainMenuView:edit()
	if not self.game.selectModel:notechartExists() then
		return
	end

	self:changeScreen("editorView")
end

function MainMenuView:notechartChanged()
	self.viewConfig:updateInfo(self)
end

function MainMenuView:resolutionUpdated()
	window_height = self.assets.localization:updateScale()

	self.viewConfig:resolutionUpdated()

	if self.modal then
		self.modal.viewConfig:resolutionUpdated()
	end
end

function MainMenuView:receive(event)
	if event.name == "mousemoved" then
		self.mouseMoveTime = love.timer.getTime()
	end

	if event.name == "keypressed" then
		if self.inputMap:call("view") then
			return
		end
	end
end

local gfx = love.graphics

function MainMenuView:drawCursor()
	gfx.origin()
	gfx.setColor(1, 1, 1)

	local x, y = love.mouse.getPosition()

	local cursor = self.assets.images.cursor
	local iw, ih = cursor:getDimensions()
	gfx.draw(cursor, x - iw / 2, y - ih / 2)
end

function MainMenuView:draw()
	gyatt.setTextScale(768 / window_height)
	self.viewConfig:draw(self)
	self:drawModal()
	self.notificationView:draw()
	self:drawCursor()
	gyatt.setTextScale(1)
end

return MainMenuView
