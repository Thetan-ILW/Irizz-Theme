local class = require("class")
local just = require("just")
local imgui = require("thetan.irizz.imgui")

local Layout = require("thetan.irizz.views.SelectView.Settings.SettingsLayout")
local SettingsTab = require("thetan.irizz.views.SelectView.Settings.SettingsTabs")

local Theme = require("thetan.irizz.views.Theme")
local Text = Theme.textSettings
local Font

local ViewConfig = class()

local tabs = {
	Text.gameplayTab,
	Text.audioTab,
	Text.videoTab,
	Text.scoring,
	Text.timingsTab,
	Text.inputsTab,
	Text.uiTab,
	Text.versionTab,
}

local currentTab = Text.gameplayTab

function ViewConfig:new(game)
	self.game = game

	Font = Theme:getFonts("settingsViewConfig")
end

local boxes = {
	"tabs",
	"settings",
}

function ViewConfig.panels()
	for _, name in pairs(boxes) do
		local w, h = Layout:move(name)
		Theme:panel(w, h)
	end
end

local function borders(view)
	for _, name in pairs(boxes) do
		local w, h = Layout:move(name)
		Theme:border(w, h)
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
			Theme:playSound("tabButtonClick")
		end
	end
end

function ViewConfig:settings(view)
	local w, h = Layout:move("settings")
	SettingsTab:draw(view, w, h, currentTab)
end

function ViewConfig.layoutDraw(position)
	Layout:draw(position)
end

function ViewConfig.canDraw(position)
	return math.abs(position) < 1
end

function ViewConfig:draw(view, position)
	if not self.canDraw(position) then
		return
	end

	just.origin()
	Layout:draw(position)

	self.panels()
	self:tabs(view)
	self:settings(view)
	borders(view)
end

return ViewConfig
