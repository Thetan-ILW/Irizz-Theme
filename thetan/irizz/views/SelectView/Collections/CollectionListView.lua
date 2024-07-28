local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")

local colors = require("thetan.irizz.ui.colors")

local CollectionListView = ListView + {}

CollectionListView.rows = 13
CollectionListView.centerItems = true

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function CollectionListView:new(game, assets)
	ListView:new(game)
	self.game = game
	self.font = assets.localization.fontGroups.collectionListView
	self.text = assets.localization.textGroups.collectionListView
	self.scrollSound = assets.sounds.scrollSmallList
end

function CollectionListView:reloadItems()
	self.stateCounter = 0
	self.items = self.game.selectModel.collectionLibrary.tree.items
end

---@return number
function CollectionListView:getItemIndex()
	local tree = self.game.selectModel.collectionLibrary.tree
	return tree.selected
end

---@return table
function CollectionListView:getItem()
	return self.items[self:getItemIndex()]
end

---@param count number
function CollectionListView:scroll(count)
	self.game.selectModel:scrollCollection(count)

	if math.abs(count) ~= 1 then
		return
	end
	self:playSound()
end

local gfx = love.graphics

---@param i number
---@param w number
---@param h number
function CollectionListView:drawItem(i, w, h)
	local tree = self.game.selectModel.collectionLibrary.tree
	local item = self.items[i]

	local name = item.name
	if item.depth == tree.depth and item.depth ~= 0 then
		name = "."
	elseif item.depth == tree.depth - 1 then
		name = ".."
	end

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	gfx.translate(15, 0)
	gfx.setColor(colors.ui.text)
	gfx.setFont(self.font.itemCount)
	gyatt.frame(item.count ~= 0 and item.count or "", 0, 0, w, h, "left", "top")
	gfx.setFont(self.font.name)
	gyatt.frame(name, 0, -5, w, h, "left", "bottom")
end

return CollectionListView
