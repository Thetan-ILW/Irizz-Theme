local ListView = require("thetan.irizz.views.ListView")
local just = require("just")
local gyatt = require("thetan.gyatt")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")
local Format = require("sphere.views.Format")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local NoteChartListView = ListView + {}

NoteChartListView.rows = 7
NoteChartListView.centerItems = true
NoteChartListView.chartInfo = {}
NoteChartListView.text = Theme.textChartList

local action
local config

function NoteChartListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("noteChartListView")
	self.scrollSound = Theme.sounds.scrollSmallList
	config = game.configModel.configs.irizz

	self.actionModel = self.game.actionModel
end

function NoteChartListView:reloadItems()
	self.stateCounter = self.game.selectModel.noteChartStateCounter
	self.items = self.game.selectModel.noteChartLibrary.items
	self.chartInfo = {}

	local timeRate = self.game.playContext.rate
	local diffColumn = self.game.configModel.configs.settings.select.diff_column

	for i, item in ipairs(self.items) do
		local diff = item.difficulty or 0

		if diffColumn == "msd_diff" and item.msd_diff_data then
			local msd = Theme.getMsdFromData(item.msd_diff_data, timeRate)
			diff = msd and msd.overall or 0
		else
			diff = diff * timeRate
		end

		local difficulty = Format.difficulty(diff)

		if diff == 0 then
			difficulty = item.level and "Lv." .. item.level or difficulty
		end

		local _inputMode = config.alwaysShowOriginalMode and item.inputmode or item.chartdiff_inputmode

		local inputMode = Format.inputMode(_inputMode)
		inputMode = inputMode == "2K" and "TAIKO" or inputMode

		local name = item.name or ""
		local creator = item.creator or ""

		self.chartInfo[i] = {
			inputMode = string.format("[%s]", inputMode),
			difficulty = difficulty,
			creator = creator,
			name = name,
		}
	end
end

---@return number
function NoteChartListView:getItemIndex()
	return self.game.selectModel.chartview_index
end

---@param count number
function NoteChartListView:scroll(count)
	self.game.selectModel:scrollNoteChart(count)

	if math.abs(count) ~= 1 then
		return
	end

	self:playSound()
end

function NoteChartListView:input(w, h)
	local delta = just.wheel_over(self, just.is_over(w, h))
	if delta then
		self:scroll(-delta)
	end

	local ap = self.actionModel.consumeAction
	local ad = self.actionModel.isActionDown

	if ad("left") then
		self:autoScroll(-1, ap("left"))
	elseif ad("right") then
		self:autoScroll(1, ap("right"))
	end
end

---@param i number
---@param w number
---@param h number
function NoteChartListView:drawItem(i, w, h)
	local item = self.chartInfo[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	love.graphics.setColor(Color.text)
	love.graphics.translate(0, 4)

	just.indent(15)
	TextCellImView(50, h, "left", item.inputMode, item.difficulty, self.font.inputMode, self.font.difficulty)

	just.sameline()
	just.indent(20)
	TextCellImView(math.huge, h, "left", item.creator, item.name, self.font.creator, self.font.name)
end

return NoteChartListView
