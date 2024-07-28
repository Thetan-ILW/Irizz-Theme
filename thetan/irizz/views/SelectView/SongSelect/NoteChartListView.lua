local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")
local Format = require("sphere.views.Format")
local msd_util = require("thetan.skibidi.msd_util")

local colors = require("thetan.irizz.ui.colors")

---@class irizz.NoteChartListView : irizz.ListView
---@operator call: irizz.NoteChartSetListView
local NoteChartListView = ListView + {}

NoteChartListView.rows = 7
NoteChartListView.centerItems = true
NoteChartListView.chartInfo = {}

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function NoteChartListView:new(game, assets)
	self.game = game
	self.config = game.configModel.configs.irizz
	self.actionModel = self.game.actionModel

	self.scrollSound = assets.sounds.scrollSmallList
	self.font = assets.localization.fontGroups.noteChartListView
	self.text = assets.localization.textGroups.noteChartListView
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
			local msd = msd_util.getMsdFromData(item.msd_diff_data, timeRate)
			diff = msd and msd.overall or 0
		else
			diff = diff * timeRate
		end

		local difficulty = Format.difficulty(diff)

		if diff == 0 then
			difficulty = item.level and "Lv." .. item.level or difficulty
		end

		local _inputMode = self.config.alwaysShowOriginalMode and item.inputmode or item.chartdiff_inputmode

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
	local delta = gyatt.wheelOver(self, gyatt.isOver(w, h))

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

local gfx = love.graphics

---@param i number
---@param w number
---@param h number
function NoteChartListView:drawItem(i, w, h)
	local item = self.chartInfo[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	gfx.setColor(colors.ui.text)
	gfx.translate(15, 4)

	gfx.setFont(self.font.firstRow)
	gyatt.frame(item.inputMode, 0, 0, math.huge, h, "left", "top")
	gfx.translate(60, 0)
	gyatt.frame(item.creator, 0, 0, math.huge, h, "left", "top")

	gfx.translate(-60, 0)
	gfx.setFont(self.font.secondRow)
	gyatt.frame(item.difficulty, 0, -5, math.huge, h, "left", "bottom")
	gfx.translate(60, 0)
	gyatt.frame(item.name, 0, -5, math.huge, h, "left", "bottom")
end

return NoteChartListView
