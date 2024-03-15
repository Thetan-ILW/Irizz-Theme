local ListView = require("thetan.irizz..views.ListView")
local just = require("just")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")
local SliderView = require("sphere.views.SliderView")
local StepperView = require("sphere.views.StepperView")
local ModifierModel = require("sphere.models.ModifierModel")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textModifiers

local ModifierListView = ListView + {}

ModifierListView.rows = 11
ModifierListView.centerItems = true
ModifierListView.noItemsText = Text.noMods
ModifierListView.scrollSound = Theme.sounds.scrollSoundLargeList

function ModifierListView:new(game)
	self.game = game
	self.font = Theme:getFonts("modifiersModal")
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
	just.indent(44)
	TextCellImView(w2 - 44, 72, "left", "", ModifierModel.Modifiers[item.id], self.font.modifierName, self.font.modifierName)

	local modifier = ModifierModel:getModifier(item.id)
	if not modifier then
		TextCellImView(w2 - 44, 72, "left", "", "Deleted modifier", self.font.modifierName, self.font.modifierName)
	elseif modifier.defaultValue == nil then
	elseif type(modifier.defaultValue) == "number" then
		just.indent(-w2)
		TextCellImView(w2, 72, "right", "", item.value, self.font.modifierName, self.font.modifierName)

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
		TextCellImView(w2, 72, "center", "", item.value, self.font.modifierName, self.font.modifierName)
		just.indent(-w2)

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
