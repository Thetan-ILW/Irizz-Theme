local ListView = require("thetan.irizz.views.ListView")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")
local just = require("just")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textCollections

local OsudirectProcessingListView = ListView + {}

OsudirectProcessingListView.rows = 11
OsudirectProcessingListView.centerItems = false
OsudirectProcessingListView.noItemsText = Text.queueEmpty

function OsudirectProcessingListView:new(game)
	self.game = game
	self.font = Theme:getFonts("osuDirectQueueListView")
end

function OsudirectProcessingListView:reloadItems()
	self.items = self.game.osudirectModel.processing
end

---@param i number
---@param w number
---@param h number
function OsudirectProcessingListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	love.graphics.translate(0, 4)
    just.indent(15)
	love.graphics.setColor(Color.text)
	TextCellImView(math.huge, h, "left", item.artist, item.title, self.font.artist, self.font.title)
end

return OsudirectProcessingListView
