local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.irizz.views.modals.ModifierModal.Layout")

local gyatt = require("thetan.gyatt")

local Format = require("sphere.views.Format")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

---@class irizz.ModifierModalViewConfig : IViewConfig
---@operator call: irizz.ModifierModalViewConfig
local ViewConfig = IViewConfig + {}

local gfx = love.graphics

---@param assets irizz.IrizzAssets
function ViewConfig:new(assets)
	font = assets.localization.fontGroups.modifiersModal
	text = assets.localization.textGroups.modifiersModal
end

function ViewConfig:availableModifierList(view)
	local w, h = Layout:move("availableMods")
	ui:panel(w, h)

	self.availableModifierListView:draw(w, h, true)
	w, h = Layout:move("availableMods")
	ui:border(w, h)
end

---@param self table
function ViewConfig:modifierList(view)
	local w, h = Layout:move("activeMods")
	ui:panel(w, h)
	self.modifierListView:draw(w, h, true)
	ui:border(w, h)
end

function ViewConfig:inputMode(view)
	local w, h = Layout:move("inputMode")

	local input_mode = view.game.selectController.state.inputMode
	input_mode = Format.inputMode(tostring(input_mode))
	input_mode = input_mode == "2K" and "TAIKO" or input_mode

	gfx.setColor(colors.ui.text)
	gfx.setFont(font.inputMode)

	gyatt.frame(input_mode, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	self.availableModifierListView:reloadItems()
	self.modifierListView:reloadItems()

	local w, h = Layout:move("modalName")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.title)
	gyatt.frame(text.modifiers, 0, 0, w, h, "center", "center")

	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)
	self:availableModifierList(view)
	self:modifierList(view)
	self:inputMode(view)
end

return ViewConfig
