local just = require("just")
local imgui = require("imgui")
local gfx_util = require("gfx_util")

local Format = require("sphere.views.Format")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textNoteSkins
local Font = Theme:getFonts("noteSkinModal")
local Container = require("thetan.gyatt.Container")

local Layout = require("thetan.irizz.views.modals.NoteSkinModal.Layout")

local ViewConfig = {}

ViewConfig.container = Container("settingsContainer")

function ViewConfig:noteSkins(view)
	local w, h = Layout:move("noteSkins")
	Theme:panel(w, h)

	self.noteSkinListView:draw(w, h, true)
	Theme:border(w, h)
end

function ViewConfig:noteSkinSettings(view)
	local w, h = Layout:move("noteSkinSettings")
	Theme:panel(w, h)
	Theme:border(w, h)

	self.selectedNoteSkin = self.noteSkinListView.selectedNoteSkin

	if not self.selectedNoteSkin then
		return
	end

	local config = self.selectedNoteSkin.config
	if not config or not config.draw then
		love.graphics.setFont(Font.noSettings)
		love.graphics.setColor(Color.text)
		gfx_util.printFrame(Text.noSettings, 0, 0, w, h, "center", "center")
		return
	end

	love.graphics.setFont(Font.noteSkinSettings)
	local startHeight = just.height
	self.container:startDraw(w, h)
	love.graphics.setColor(Color.text)
	config:draw(w, h)
	self.container.scrollLimit = just.height - startHeight - h
	self.container.stopDraw()
end

function ViewConfig:noteSkinName(view)
	local w, h = Layout:move("selectedNoteSkin")

	if not self.noteSkinListView.selectedNoteSkin then
		return
	end

	local inputMode = self.noteSkinListView.inputMode
	local skinName = self.noteSkinListView.selectedNoteSkin.name
	inputMode = Format.inputMode(inputMode)
	inputMode = inputMode == "2K" and "TAIKO" or inputMode

	local text = string.format("[%s] %s", inputMode, skinName)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.skinName)
	gfx_util.printFrame(text, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	self.noteSkinListView:reloadItems()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.noteSkins, 0, 0, w, h, "center", "center")

	self:noteSkins(view)
	self:noteSkinSettings(view)
	self:noteSkinName(view)
end

return ViewConfig
