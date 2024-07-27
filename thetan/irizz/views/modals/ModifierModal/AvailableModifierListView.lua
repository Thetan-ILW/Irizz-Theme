local ListView = require("thetan.irizz.views.ListView")
local just = require("just")

local gyatt = require("thetan.gyatt")
local ModifierModel = require("sphere.models.ModifierModel")

local AvailableModifierListView = ListView + {}

AvailableModifierListView.rows = 11
AvailableModifierListView.centerItems = false

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function AvailableModifierListView:new(game, assets)
	self.game = game
	self.font = assets.localization.fontGroups.modifiersModal
	self.text = assets.localization.textGroups.modifiersModal
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
	gyatt.frame(mod.name, 15, 0, w - 44, h, "left", "center")
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
		gyatt.frame(text, 0, 15, w - 22, h / 4, "right", "center")
	end
	just.row()
end

return AvailableModifierListView
