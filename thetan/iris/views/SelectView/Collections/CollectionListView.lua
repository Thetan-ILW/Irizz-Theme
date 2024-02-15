local ListView = require("thetan.iris.views.ListView")
local just = require("just")
local TextCellImView = require("thetan.iris.imviews.TextCellImView")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textCollections

local CollectionListView = ListView + {}

CollectionListView.rows = 13
CollectionListView.centerItems = true
CollectionListView.noItemsText = Text.noCollections
CollectionListView.scrollSound = Theme.sounds.scrollSoundLargeList

function CollectionListView:new(game)
	self.game = game
	self.font = Theme:getFonts("collectionsListView")
end

function CollectionListView:reloadItems()
	self.items = self.game.selectModel.collectionLibrary.items
	self.selectedCollection = self.game.selectModel.collectionItem
end

---@return number
function CollectionListView:getItemIndex()
	return self.game.selectModel.collectionItemIndex
end

---@return table
function CollectionListView:getItem()
	return self.items[self:getItemIndex()]
end

---@param count number
function CollectionListView:scroll(count)
	self.game.selectModel:scrollCollection(count)
	self:playSound()
end

---@param i number
---@param w number
---@param h number
function CollectionListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	love.graphics.setColor(Color.text)
	love.graphics.translate(0, 4)
	just.indent(15)
	TextCellImView(48, h, "left", "", item.count ~= 0 and item.count or "", self.font.itemCount, self.font.itemCount)

	just.sameline()
	just.indent(20)
	TextCellImView(math.huge, h, "left", item.shortPath, item.name, self.font.shortPath, self.font.name)
end

return CollectionListView
