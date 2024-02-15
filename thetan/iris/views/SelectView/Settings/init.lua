local class = require("class")
local just = require("just")
local imgui = require("thetan.iris.imgui")

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
	Text.versionTab,
}

local currentTab = Text.gameplayTab

function ViewConfig:new(game)
	Font = Theme:getFonts("settingsViewConfig")
end

local boxes = {
	"tabs",
	"settings",
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
		love.graphics.rectangle("line", -2, -2, w + 3, h + 3)
	end
end

function ViewConfig:tabs(view)
	local w, h = Layout:move("tabs")

	local tabsCount = #tabs
	h = h / tabsCount

	love.graphics.setFont(Font.tabs)

	for _, tab in ipairs(tabs) do
		if imgui.TextOnlyButton(tab, tab, w, h, "center", tab == currentTab) then
			currentTab = tab
			SettingsTab:reset()
		end
	end
end

function ViewConfig:settings(view)
	local w, h = Layout:move("settings")
	SettingsTab:draw(view, w, h, currentTab)
end

function ViewConfig:draw(view, position)
	if math.abs(position) >= 1 then
		return
	end

	just.origin()
	Layout:draw(position)

	Frames(view)
	self:tabs(view)
	self:settings(view)
	Borders(view)
end

return ViewConfig
