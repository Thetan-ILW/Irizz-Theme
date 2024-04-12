local just = require("just")
local gfx_util = require("gfx_util")

local Format = require("sphere.views.Format")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textModifiers
local Font = Theme:getFonts("modifiersModal")

local Layout = require("thetan.irizz.views.modals.ModifierModal.Layout")

local ViewConfig = {}

function ViewConfig:availableModifierList(view)
	local w, h = Layout:move("availableMods")
	Theme:panel(w, h)

	self.availableModifierListView:draw(w, h, true)
	w, h = Layout:move("availableMods")
	Theme:border(w, h)
end

---@param self table
function ViewConfig:modifierList(view)
	local w, h = Layout:move("activeMods")
	Theme:panel(w, h)
	self.modifierListView:draw(w, h, true)
	Theme:border(w, h)
end

function ViewConfig:inputMode(view)
	local w, h = Layout:move("inputMode")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.inputMode)
	local inputMode = view.game.selectController.state.inputMode
	inputMode = Format.inputMode(tostring(inputMode))
	inputMode = inputMode == "2K" and "TAIKO" or inputMode

	gfx_util.printFrame(inputMode, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	self.availableModifierListView:reloadItems()
	self.modifierListView:reloadItems()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.modifiers, 0, 0, w, h, "center", "center")

	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)
	self:availableModifierList(view)
	self:modifierList(view)
	self:inputMode(view)
end

return ViewConfig
