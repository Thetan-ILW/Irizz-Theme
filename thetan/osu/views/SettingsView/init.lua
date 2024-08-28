local class = require("class")
local gyatt = require("thetan.gyatt")
local flux = require("flux")
local math_util = require("math_util")

local consts = require("thetan.osu.views.SettingsView.Consts")
local ViewConfig = require("thetan.osu.views.SettingsView.ViewConfig")
local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Label = require("thetan.osu.ui.Label")
local Button = require("thetan.osu.ui.Button")
local Checkbox = require("thetan.osu.ui.Checkbox")
local Spacing = require("thetan.osu.ui.Spacing")

---@class osu.SettingsView
---@operator call: osu.SettingsView
---@field assets osu.OsuAssets
---@field state "hidden" | "fade_in" | "visible" | "fade_out"
---@field visibility number
---@field visibilityTween table?
---@field scrollPosition number
---@field scrollTargetPosition number
---@field scrollTween table?
---@field hoverPosition number
---@field hoverSize number
---@field containers osu.SettingsView.GroupContainer[]
---@field totalHeight number
---@field topSpacing osu.ui.Spacing
---@field headerSpacing osu.ui.Spacing
---@field bottomSpacing osu.ui.Spacing
---@field optionsLabel osu.ui.Label
---@field gameBehaviorLabel osu.ui.Label
local SettingsView = class()

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

---@param assets osu.OsuAssets
function SettingsView:new(assets)
	self.assets = assets
	self.viewConfig = ViewConfig(assets)
	self.visibility = 0
	self.state = "hidden"
	self.scrollPosition = 0
	self.scrollTargetPosition = 0
	self.containers = {}
	self.totalHeight = 0

	text, font = assets.localization:get("settings")
	assert(font)

	self:build()
end

function SettingsView:build()
	gyatt.setTextScale(768 / love.graphics.getHeight())
	self.containers = {}
	self.topSpacing = Spacing(64)
	self.headerSpacing = Spacing(30)
	self.bottomSpacing = Spacing(64)

	self.optionsLabel = Label({
		text = "Options",
		width = 438,
		font = font.optionsLabel,
	})

	self.gameBehaviorLabel = Label({
		text = "Change the way soundsphere behaves",
		width = 438,
		font = font.gameBehaviorLabel,
		color = { 0.83, 0.38, 0.47, 1 },
	})

	local assets = self.assets
	local btn_w = consts.buttonWidth
	local btn_s = consts.buttonSize

	local test_container = GroupContainer("SKIN", font)
	test_container:createGroup("skin", "SKIN")
	test_container:add(
		"skin",
		Button(assets, {
			text = "Preview gameplay",
			font = font.buttons,
			width = btn_w,
			scale = btn_s,
			color = { 0.83, 0.38, 0.47, 1 },
		}, function() end)
	)
	test_container:add(
		"skin",
		Button(assets, {
			text = "Open current skin folder",
			font = font.buttons,
			width = btn_w,
			scale = btn_s,
			color = { 0.06, 0.51, 0.64, 1 },
		}, function() end)
	)

	local checkbox_test = false

	test_container:add(
		"skin",
		Checkbox(assets, { text = "Show PP", font = font.checkboxes, pixelHeight = 37, pixelWidth = 404 }, function()
			return checkbox_test
		end, function()
			checkbox_test = not checkbox_test
		end)
	)

	test_container:createGroup("graphics", "GRAPHICS")
	for i = 1, 20 do
		test_container:add(
			"graphics",
			Button(assets, {
				text = "Apply resolution " .. i,
				font = font.buttons,
				width = btn_w,
				scale = btn_s,
				color = { 0.06, 0.51, 0.64, 1 },
			}, function() end)
		)
	end

	local second_container = GroupContainer("AUDIO", font)
	second_container:createGroup("audio", "AUDIO")
	for i = 1, 20 do
		second_container:add(
			"audio",
			Button(assets, {
				text = "audio " .. i,
				font = font.buttons,
				width = btn_w,
				scale = btn_s,
				color = { 0.06, 0.51, 0.64, 1 },
			}, function() end)
		)
	end

	table.insert(self.containers, test_container)
	table.insert(self.containers, second_container)

	------------- Setting positions and heights
	local pos = self.optionsLabel:getHeight()
	pos = pos + self.gameBehaviorLabel:getHeight()
	pos = pos + self.topSpacing:getHeight()
	pos = pos + self.headerSpacing:getHeight()

	for i, c in ipairs(self.containers) do
		c:updateHeight()
		c.position = pos
		pos = pos + c.height
	end

	------------- Scroll limit
	pos = self.optionsLabel:getHeight()
	pos = pos + self.gameBehaviorLabel:getHeight()
	pos = pos + self.topSpacing:getHeight()
	pos = pos + self.headerSpacing:getHeight()
	pos = pos + self.bottomSpacing:getHeight()

	for _, c in ipairs(self.containers) do
		pos = pos + c.height
	end

	self.totalHeight = pos
end

---@private
function SettingsView:open()
	if self.visibilityTween then
		self.visibilityTween:stop()
	end
	self.visibilityTween = flux.to(self, 0.5, { visibility = 1 }):ease("quadout")
	self.state = "fade_in"
end

---@private
function SettingsView:close()
	if self.visibilityTween then
		self.visibilityTween:stop()
	end
	self.visibilityTween = flux.to(self, 0.5, { visibility = 0 }):ease("quadout")
	self.state = "fade_out"
end

---@param event? "toggle" | "hide"
function SettingsView:processState(event)
	local state = self.state
	local toggle = event == "toggle"

	if state == "hidden" then
		if toggle then
			self:open()
		end
	elseif state == "fade_in" then
		if self.visibility == 1 then
			self.state = "visible"
			return
		end
		if toggle or event == "hide" then
			self:close()
		end
	elseif state == "fade_out" then
		if self.visibility == 0 then
			self.state = "hidden"
			return
		end
		if toggle then
			self:open()
		end
	elseif state == "visible" then
		if toggle or event == "hide" then
			self:close()
		end
	end
end

function SettingsView:isFocused()
	return (not self.state == "hidden") or self.viewConfig.focus
end

function SettingsView:update(dt)
	self:processState()

	local additional_pos = 0.0

	for i, c in ipairs(self.containers) do
		if c.hoverPosition ~= 0 then
			self.hoverPosition = c.hoverPosition + additional_pos
			self.hoverSize = c.hoverSize
		end

		additional_pos = additional_pos + c.height + consts.groupSpacing
	end
end

function SettingsView:resolutionUpdated()
	--self:build() It will build it two times when you open MainMenu
end

---@param event table
function SettingsView:receive(event)
	if event.name == "wheelmoved" and self.state ~= "hidden" and self.viewConfig.focus then
		---@type number
		local delta = -event[2]
		local max = math_util.clamp(self.totalHeight - 768, 0, self.totalHeight - 768)
		self.scrollTargetPosition = math_util.clamp(self.scrollTargetPosition + (delta * 50), 0, max)

		flux.to(self, 0.1, { scrollPosition = -self.scrollTargetPosition }):ease("quadout")
	end
end

function SettingsView:draw()
	if self.state == "hidden" then
		return
	end

	self.viewConfig:draw(self)
end

return SettingsView
