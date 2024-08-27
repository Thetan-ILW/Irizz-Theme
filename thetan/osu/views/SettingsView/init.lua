local class = require("class")
local flux = require("flux")

local ViewConfig = require("thetan.osu.views.SettingsView.ViewConfig")

---@class osu.SettingsView
---@operator call: osu.SettingsView
---@field state "hidden" | "fade_in" | "visible" | "fade_out"
---@field visibility number
---@field visibilityTween table?
local SettingsView = class()

function SettingsView:new()
	self.viewConfig = ViewConfig()
	self.visibility = 0
	self.state = "hidden"
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

function SettingsView:draw()
	if self.state == "hidden" then
		return
	end

	self.viewConfig:draw(self)
end

return SettingsView
