local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")
local just = require("just")

local SliderView = require("sphere.views.SliderView")
local StepperView = require("sphere.views.StepperView")
local ModifierModel = require("sphere.models.ModifierModel")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local ModifierListView = ListView + {}

ModifierListView.rows = 11
ModifierListView.centerItems = true

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ModifierListView:new(game, assets)
	ListView:new(game)
	self.game = game
	self.font = assets.localization.fontGroups.modifiersModal
	self.text = assets.localization.textGroups.modifiersModal
end

function ModifierListView:reloadItems()
	self.items = self.game.playContext.modifiers
end

---@return number
function ModifierListView:getItemIndex()
	return self.game.modifierSelectModel.modifierIndex
end

---@param count number
function ModifierListView:scroll(count)
	self.game.modifierSelectModel:scrollModifier(count)
end

local gfx = love.graphics

---@param i number
---@param w number
---@param h number
function ModifierListView:drawItem(i, w, h)
	local modifierSelectModel = self.game.modifierSelectModel

	local item = self.items[i]
	local w2 = w / 2

	local changed, active, hovered = just.button(tostring(item) .. "1", just.is_over(w2, h), 2)
	if changed then
		modifierSelectModel:remove(i)
	end

	self:drawItemBody(w, h, i, hovered)
	love.graphics.setColor(Color.text)

	just.row(true)

	gfx.setFont(self.font.modifierName)

	gfx.translate(15, 0)
	gyatt.frame(ModifierModel.Modifiers[item.id] or "NONE", 0, 0, math.huge, h, "left", "center")

	local modifier = ModifierModel:getModifier(item.id)
	if not modifier then
		gyatt.frame("DELETED MODIFIER", 0, 0, math.huge, h, "left", "top")
	elseif modifier.defaultValue == nil then
	elseif type(modifier.defaultValue) == "number" then
		gyatt.frame(item.value, 0, 0, 265, h, "right", "center")
		gfx.translate(265, 0)

		local value = modifier:toNormValue(item.value)

		local over = SliderView:isOver(w2, h)
		local pos = SliderView:getPosition(w2, h)

		local delta = just.wheel_over(item, over)
		local new_value = just.slider(item, over, pos, value)
		if new_value then
			ModifierModel:setModifierValue(item, modifier:fromNormValue(new_value))
			modifierSelectModel:change()
		elseif delta then
			ModifierModel:increaseModifierValue(item, delta)
			modifierSelectModel:change()
		end
		SliderView:draw(w2, h, value)
	elseif type(modifier.defaultValue) == "string" then
		gyatt.frame(item.value, 0, 0, 280, h, "right", "center")
		gfx.translate(280, 0)

		local value = modifier:toIndexValue(item.value)
		local count = modifier:getCount()

		local overAll, overLeft, overRight = StepperView:isOver(w2, h)

		local id = tostring(item)
		local delta = just.wheel_over(id .. "A", overAll)
		local changedLeft = just.button(id .. "L", overLeft)
		local changedRight = just.button(id .. "R", overRight)

		if changedLeft or delta == -1 then
			ModifierModel:increaseModifierValue(item, -1)
			modifierSelectModel:change()
		elseif changedRight or delta == 1 then
			ModifierModel:increaseModifierValue(item, 1)
			modifierSelectModel:change()
		end
		StepperView:draw(w2, h, value, count)
	end
	just.row()
end

return ModifierListView
