local ListView = require("thetan.irizz.views.ListView")
local just = require("just")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect

local NoteChartSetListView = ListView + {}

NoteChartSetListView.rows = 13
NoteChartSetListView.centerItems = true
NoteChartSetListView.noItemsText = Text.noChartSets
NoteChartSetListView.scrollSound = Theme.sounds.scrollSoundLargeList

function NoteChartSetListView:new(game)
	self.game = game
	self.font = Theme:getFonts("noteChartSetListView")
end

function NoteChartSetListView:reloadItems()
	self.stateCounter = self.game.selectModel.noteChartSetStateCounter
	self.items = self.game.selectModel.noteChartSetLibrary.items
end

---@return number
function NoteChartSetListView:getItemIndex()
	return self.game.selectModel.chartview_set_index
end

---@param count number
function NoteChartSetListView:scroll(count)
	self.game.selectModel:scrollNoteChartSet(count)
	if math.abs(count) ~= 1 then
		return
	end
	self.direction = count
	self:playSound()
end

---@param i number
---@param w number
---@param h number
function NoteChartSetListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	love.graphics.setColor(Color.text)
	love.graphics.translate(0, 4)
	just.indent(15)
	TextCellImView(math.huge, h, "left", item.artist, item.title, self.font.artist, self.font.title)
end

return NoteChartSetListView
