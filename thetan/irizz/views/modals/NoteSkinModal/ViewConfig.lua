local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.irizz.views.modals.NoteSkinModal.Layout")

local gyatt = require("thetan.gyatt")
local just = require("just")

local Format = require("sphere.views.Format")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local NoteSkinListView = require("thetan.irizz.views.modals.NoteSkinModal.NoteSkinListView")
local Container = require("thetan.gyatt.Container")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ViewConfig = IViewConfig + {}

---@param game sphere.GameController
---@param assets  irizz.IrizzAssets
function ViewConfig:new(game, assets)
	self.container = Container("settingsContainer")
	self.noteSkinListView = NoteSkinListView(game, assets)

	text, font = assets.localization:get("noteSkinsModal")
	assert(text and font)
end

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
		love.graphics.setFont(font.noSettings)
		love.graphics.setColor(Color.text)
		gyatt.frame(text.noSettings, 0, 0, w, h, "center", "center")
		return
	end

	love.graphics.setFont(font.noteSkinSettings)
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

	local label = string.format("[%s] %s", inputMode, skinName)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.skinName)
	gyatt.frame(label, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	self.noteSkinListView:reloadItems()

	local w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.title)
	gyatt.frame(text.noteSkins, 0, 0, w, h, "center", "center")

	self:noteSkins(view)
	self:noteSkinSettings(view)
	self:noteSkinName(view)
end

return ViewConfig
