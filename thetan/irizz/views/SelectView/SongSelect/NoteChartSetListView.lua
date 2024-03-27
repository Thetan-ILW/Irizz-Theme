local ListView = require("thetan.irizz.views.ListView")
local just = require("just")
local time_util = require("time_util")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect

local NoteChartSetListView = ListView + {}

NoteChartSetListView.rows = 13
NoteChartSetListView.centerItems = true
NoteChartSetListView.noItemsText = Text.noChartSets

function NoteChartSetListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("noteChartSetListView")
	self.scrollSound = Theme.sounds.scrollLargeList
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

	local irizz = self.game.configModel.configs.irizz
	local drawLength = irizz.chartLengthBeforeArtist

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	local length = time_util.format((item.duration or 0) / self.game.playContext.rate)
	local firstLine

	if drawLength then
		firstLine = ("[%s] %s"):format(length, item.artist)
	else
		firstLine = item.artist
	end

	love.graphics.setColor(Color.text)
	love.graphics.translate(0, 4)
	just.indent(15)

	TextCellImView(math.huge, h, "left", firstLine, item.title, self.font.artist, self.font.title)
end

return NoteChartSetListView
