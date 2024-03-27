local ListView = require("thetan.irizz.views.ListView")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")
local just = require("just")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local OsudirectListView = ListView + {}

OsudirectListView.rows = 13
OsudirectListView.centerItems = true

function OsudirectListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("osuDirectListView")
	self.scrollSound = Theme.sounds.scrollLargeList
end

function OsudirectListView:reloadItems()
	self.items = self.game.osudirectModel.items
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

---@param count number
function OsudirectListView:scroll(count)
	ListView.scroll(self, count)
	self.game.osudirectModel:setBeatmap(self.items[self.targetItemIndex])
	self:playSound()
end

---@param i number
---@param w number
---@param h number
function OsudirectListView:drawItem(i, w, h)
	local item = self.items[i]
	local color = item.downloaded and Color.itemDownloaded or Color.text

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	love.graphics.setColor(color)
	love.graphics.translate(0, 4)
	just.indent(15)
	TextCellImView(math.huge, h, "left", item.artist, item.title, self.font.artist, self.font.title)
end

return OsudirectListView
