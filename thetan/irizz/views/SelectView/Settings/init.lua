local class = require("class")
local just = require("just")
local imgui = require("thetan.irizz.imgui")

local Layout = require("thetan.irizz.views.SelectView.Settings.SettingsLayout")
local SettingsTab = require("thetan.irizz.views.SelectView.Settings.SettingsTabs")

local Theme = require("thetan.irizz.views.Theme")
---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ViewConfig = class()

local tabs = {
	{ "gameplayTab", "Gameplay" },
	{ "audioTab", "Audio" },
	{ "videoTab", "Video" },
	{ "scoring", "Scoring" },
	{ "timingsTab", "Timings" },
	{ "inputsTab", "Inputs" },
	{ "uiTab", "UI" },
	{ "versionTab", "Version" },
}

local currentTab = tabs[1][2]

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ViewConfig:new(game, assets)
	self.game = game

	font = assets.localization.fontGroups.settings
	text = assets.localization.textGroups.settings

	self.settingsPanel = SettingsTab(game, assets)
end

function ViewConfig:focused()
	self.settingsPanel:updateItems(self)
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

	love.graphics.setFont(font.tabs)

	for i, tab in ipairs(tabs) do
		local label = text[tab[1]]
		local methodName = tab[2]
		if imgui.TextOnlyButton(label, label, w, h, "center", methodName == currentTab) then
			currentTab = methodName
			SettingsTab:reset()
			Theme:playSound("tabButtonClick")
		end
	end
end

function ViewConfig:settings(view)
	local w, h = Layout:move("settings")
	self.settingsPanel:draw(view, w, h, currentTab)
end

function ViewConfig.layoutDraw(position)
	Layout:draw(position)
end

function ViewConfig.canDraw(position)
	return math.abs(position) < 1
end

function ViewConfig:draw(view, position)
	position = position or 0

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
