local ListView = require("thetan.iris.views.ListView")
local just = require("just")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")
local ModifierModel = require("sphere.models.ModifierModel")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textModifiers

local AvailableModifierListView = ListView + {}

AvailableModifierListView.rows = 11
AvailableModifierListView.centerItems = false
AvailableModifierListView.noItemsText = Text.noMods
AvailableModifierListView.scrollSound = Theme.sounds.scrollSoundLargeList

function AvailableModifierListView:new(game)
	self.game = game
	self.font = Theme:getFonts("modifiersModal")
end

function AvailableModifierListView:reloadItems()
	self.items = self.game.modifierSelectModel.modifiers
end

---@return number
function AvailableModifierListView:getItemIndex()
	return self.game.modifierSelectModel.availableModifierIndex
end

---@param count number
function AvailableModifierListView:scroll(count)
	self.game.modifierSelectModel:scrollAvailableModifier(count)
end

---@param i number
---@param w number
---@param h number
function AvailableModifierListView:drawItem(i, w, h)
	local modifierSelectModel = self.game.modifierSelectModel

	local item = self.items[i]
	local prevItem = self.items[i - 1]

	local id = "Available modifier" .. i
	local changed, active, hovered = just.button(id, just.is_over(w, h))
	if changed then
		local modifier = modifierSelectModel.modifiers[i]
		modifierSelectModel:add(modifier)
	end

	self:drawItemBody(w, h, i, hovered)

	love.graphics.setColor(1, 1, 1, 1)

	if modifierSelectModel:isOneUse(item) and modifierSelectModel:isAdded(item) then
		love.graphics.setColor(1, 1, 1, 0.5)
	end

	local mod = ModifierModel:getModifier(item)

	just.row(true)
	love.graphics.setFont(self.font.modifierName)
	gfx_util.printFrame(mod.name, 15, 0, w - 44, h, "left", "center")
	if just.mouse_over(id, just.is_over(w, h), "mouse") then
		self.game.gameView.tooltip = mod.description
	end

	love.graphics.setColor(1, 1, 1, 1)
	if not prevItem or modifierSelectModel:isOneUse(prevItem) ~= modifierSelectModel:isOneUse(item) then
		local text = "One use modifiers"
		if not modifierSelectModel:isOneUse(item) then
			text = "Sequential modifiers"
		end
		love.graphics.setFont(self.font.numberOfUses)
		gfx_util.printFrame(text, 0, 15, w - 22, h / 4, "right", "center")
	end
	just.row()
end

return AvailableModifierListView
