local class = require("class")
local just = require("just")
local gfx_util = require("gfx_util")

local Layout = require("thetan.iris.views.SelectView.Settings.SettingsLayout")
local SettingsTab = require("thetan.iris.views.SelectView.Settings.SettingsTabs")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textSettings
local Font

local ViewConfig = class()

local tabs = {
	Text.gameplayTab,
	Text.audioTab,
	Text.videoTab,
	Text.timingsTab,
	Text.keybindsTab,
	Text.inputsTab,
	Text.uiTab,
	Text.versionTab
}

local currentTab = Text.gameplayTab

function ViewConfig:new(game)
	Font = Theme:getFonts("settingsViewConfig")
end

local boxes = {
	"tabs",
	"settings"
}

local function Frames(view)
	for i, name in pairs(boxes) do
		local w, h = Layout:move(name)
		love.graphics.setColor(Color.panel)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
end

local function Borders(view)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)

	for i, name in pairs(boxes) do
		local w, h = Layout:move(name)
		love.graphics.setColor(Color.border)
		love.graphics.rectangle("line", -2, -2, w+3, h+3)
	end
end

function ViewConfig:tabs(view)
	local w, h = Layout:move("tabs")

	local tabsCount = #tabs
	h = h / (tabsCount)

	love.graphics.setFont(Font.tabs)

	for _, tab in ipairs(tabs) do
		local changed, active, hovered = just.button(tab, just.is_over(w, h), 1)
		if changed then
			currentTab = tab
			SettingsTab:reset()
		end

		local color = hovered and Color.buttonHover or Color.button
		color = (currentTab == tab) and Color.select or color

		love.graphics.setColor(color)
		love.graphics.rectangle("fill", 0, 2, w, h-2)
		love.graphics.setColor(Color.mutedBorder)
		love.graphics.rectangle("fill", w/2 - w/4, h-2, w/2, 4)
		love.graphics.setColor(Color.text)
		gfx_util.printBaseline(tab, 0, h/1.5, w, 1, "center")

		just.next(0, h)
	end
end

function ViewConfig:settings(view)
	local w, h = Layout:move("settings")
	SettingsTab:draw(view, w, h, currentTab)
end

function ViewConfig:draw(view)
	Frames(view)
	self:tabs(view)
	self:settings(view)
	Borders(view)
end

return ViewConfig