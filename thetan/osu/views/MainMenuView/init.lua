local ScreenView = require("thetan.skibidi.views.ScreenView")

local gyatt = require("thetan.gyatt")
local ViewConfig = require("thetan.osu.views.MainMenuView.ViewConfig")

local get_assets = require("thetan.osu.views.assets_loader")

---@class osu.MainMenuView : skibidi.ScreenView
---@operator call: osu.MainMenuView
local MainMenuView = ScreenView + {}

local window_height = 0

function MainMenuView:load()
	self.game.selectController:load(self)

	self.assets = get_assets(self.game)
	self.viewConfig = ViewConfig(self.game, self.assets)

	window_height = love.graphics.getHeight()
	love.mouse.setVisible(false)
end

function MainMenuView:beginUnload()
	self.game.selectController:beginUnload()
end

function MainMenuView:unload()
	self.game.selectController:unload()
end

---@param dt number
function MainMenuView:update(dt)
	self.game.selectController:update()
end

function MainMenuView:notechartChanged() end

function MainMenuView:resolutionUpdated()
	window_height = self.assets.localization:updateScale()

	self.viewConfig:resolutionUpdated()

	if self.modal then
		self.modal.viewConfig:resolutionUpdated()
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
	self:drawCursor()
	gyatt.setTextScale(1)
end

return MainMenuView
