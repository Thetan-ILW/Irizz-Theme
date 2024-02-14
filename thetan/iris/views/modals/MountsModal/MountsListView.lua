local ListView = require("thetan.iris.views.ListView")
local just = require("just")
local gfx_util = require("gfx_util")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textMounts

local MountsListView = ListView + {}

MountsListView.rows = 11
MountsListView.centerItems = false
MountsListView.noItemsText = Text.noMounts
MountsListView.scrollSound = Theme.sounds.scrollSoundLargeList
MountsListView.selectedItem = nil

function MountsListView:new(game)
	self.game = game
	self.font = Theme:getFonts("mountsModal")
end

function MountsListView:reloadItems()
	self.items = self.game.configModel.configs.mount

	if not self.selectedItem then
		self.selectedItem = self.items[1]
	end
end

---@return number
function MountsListView:getItemIndex()
	return self.game.modifierSelectModel.availableModifierIndex
end

---@param count number
function MountsListView:scroll(count)
	self.game.modifierSelectModel:scrollAvailableModifier(count)
end

---@param i number
---@param w number
---@param h number
function MountsListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, self.selectedItem == item)

	local changed, active, hovered = just.button("mount" .. i, just.is_over(w, h))
	if changed then
		self.selectedItem = item
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.mountPaths)
	love.graphics.translate(15, 10)
	just.text(item[1]:match("^.+/(.+)$"), math.huge)
end

return MountsListView
