local ListView = require("thetan.iris.views.ListView")
local just = require("just")
local TextCellImView = require("thetan.iris.imviews.TextCellImView")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect
local Font

local NoteChartSetListView = ListView + {}

NoteChartSetListView.rows = 13
NoteChartSetListView.centerItems = true
NoteChartSetListView.noItemsText = Text.noChartSets

function NoteChartSetListView:new(game)
	self:crap(game)
	Font = Theme:getFonts("noteChartSetListView")
end

function NoteChartSetListView:reloadItems()
	self.stateCounter = self.game.selectModel.noteChartSetStateCounter
	self.items = self.game.selectModel.noteChartSetLibrary.items
end

---@return number
function NoteChartSetListView:getItemIndex()
	return self.game.selectModel.noteChartSetItemIndex
end

---@param count number
function NoteChartSetListView:scroll(count)
	self.game.selectModel:scrollNoteChartSet(count)
	if (math.abs(count) ~= 1) then
		return
	end
	self.direction = count
	self:playSound()
end

---@param ... any?
function NoteChartSetListView:draw(...)
	ListView.draw(self, ...)
end

function NoteChartSetListView:update()
	local kp = just.keypressed
	if kp("left") then self:scroll(-1)
	elseif kp("right") then self:scroll(1)
	elseif kp("pageup") then self:scroll(-10)
	elseif kp("pagedown") then self:scroll(10)
	elseif kp("home") then self:scroll(-math.huge)
	elseif kp("end") then self:scroll(math.huge)
	end
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
	TextCellImView(math.huge, h, "left", item.artist, item.title,
		Font.artist,
		Font.title
	)
end

return NoteChartSetListView
