local ListView = require("thetan.irizz.views.ListView")
local just = require("just")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local CollectionListView = ListView + {}

CollectionListView.rows = 13
CollectionListView.centerItems = true
CollectionListView.text = Theme.textOsuDirectList

function CollectionListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("collectionsListView")
	self.scrollSound = Theme.sounds.scrollLargeList
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
	self:playSound()
end

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

	love.graphics.setColor(Color.text)
	love.graphics.translate(0, 4)
	just.indent(15)
	TextCellImView(
		math.huge,
		h,
		"left",
		item.count ~= 0 and item.count or "",
		name,
		self.font.itemCount,
		self.font.name
	)
end

return CollectionListView
