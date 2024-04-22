local ListView = require("thetan.irizz.views.ListView")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")
local just = require("just")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local OsudirectProcessingListView = ListView + {}

OsudirectProcessingListView.rows = 11
OsudirectProcessingListView.centerItems = false
OsudirectProcessingListView.text = Theme.textQueueList

function OsudirectProcessingListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("osuDirectQueueListView")
end

function OsudirectProcessingListView:reloadItems()
	self.items = self.game.osudirectModel.processing
end

function OsudirectProcessingListView:input() end

---@param i number
---@param w number
---@param h number
function OsudirectProcessingListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())
	love.graphics.translate(0, 4)
	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.status)
	just.indent(-15)

	if item.status then
		gyatt.frame(item.status, 0, 0, w, h, "right", "top")
	end

	just.indent(30)
	TextCellImView(math.huge, h, "left", item.artist, item.title, self.font.artist, self.font.title)
end

return OsudirectProcessingListView
