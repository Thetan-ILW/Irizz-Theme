local ListView = require("thetan.iris.views.ListView")
local TextCellImView = require("thetan.iris.imviews.TextCellImView")
local just = require("just")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textCollections
local Font

local OsuDirectChartsListView = ListView + {}

OsuDirectChartsListView.rows = 7
OsuDirectChartsListView.centerItems = true
OsuDirectChartsListView.noItemsText = Text.notInOsuDirect

function OsuDirectChartsListView:new(game)
    self:crap(game)
    Font = Theme:getFonts("osuDirectChartsListView")
end

function OsuDirectChartsListView:reloadItems()
	self.items = self.game.osudirectModel:getDifficulties()
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

---@param i number
---@param w number
---@param h number
function OsuDirectChartsListView:drawItem(i, w, h)
	local item = self.items[i]
    self:drawItemBody(w, h, i, i == self:getItemIndex())

    love.graphics.setColor(Color.text)
	love.graphics.translate(0, 4)
	just.indent(15)
	TextCellImView(math.huge, h, "left", item.beatmapset.creator, item.version, Font.creator, Font.difficultyName)
end

return OsuDirectChartsListView
