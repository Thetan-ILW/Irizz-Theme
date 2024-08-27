local class = require("class")
local flux = require("flux")
local math_util = require("math_util")

local ViewConfig = require("thetan.osu.views.SettingsView.ViewConfig")
local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Button = require("thetan.osu.ui.Button")

---@class osu.SettingsView
---@operator call: osu.SettingsView
---@field state "hidden" | "fade_in" | "visible" | "fade_out"
---@field visibility number
---@field visibilityTween table?
---@field scrollPosition number
---@field scrollTargetPosition number
---@field scrollTween table?
---@field containers table<string, osu.SettingsView.GroupContainer>
---@field totalContainerHeight number
local SettingsView = class()

---@param assets osu.OsuAssets
function SettingsView:new(assets)
	self.viewConfig = ViewConfig(assets)
	self.visibility = 0
	self.state = "hidden"
	self.scrollPosition = 0
	self.scrollTargetPosition = 0
	self.containers = {}
	self.totalContainerHeight = 0

	local text, font = assets.localization:get("settings")
	assert(font)

	local btn_w = 2.65
	local btn_s = 0.5

	local test_container = GroupContainer(font)
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

	test_container:createGroup("graphics", "GRAPHICS")
	test_container:add(
		"graphics",
		Button(assets, {
			text = "Apply resolution",
			font = font.buttons,
			width = btn_w,
			scale = btn_s,
			color = { 0.06, 0.51, 0.64, 1 },
		}, function() end)
	)

	self.containers["test"] = test_container

	for _, c in pairs(self.containers) do
		self.totalContainerHeight = self.totalContainerHeight + c.height
	end
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
end

---@param event table
function SettingsView:receive(event)
	if event.name == "wheelmoved" and self.state ~= "hidden" and self.viewConfig.focus then
		---@type number
		local delta = -event[2]
		self.scrollTargetPosition =
			math_util.clamp(self.scrollTargetPosition + (delta * 50), 0, self.totalContainerHeight)

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
