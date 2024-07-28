local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")
local time_util = require("time_util")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

---@class irizz.NoteChartSetListView : irizz.ListView
---@operator call: irizz.NoteChartSetListView
local NoteChartSetListView = ListView + {}

NoteChartSetListView.rows = 13
NoteChartSetListView.centerItems = true

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function NoteChartSetListView:new(game, assets)
	self.game = game

	self.scrollSound = assets.sounds.scrollLargeList
	self.font = assets.localization.fontGroups.noteChartSetListView
	self.text = assets.localization.textGroups.noteChartSetListView
end

function NoteChartSetListView:reloadItems()
	self.stateCounter = self.game.selectModel.noteChartSetStateCounter
	self.items = self.game.selectModel.noteChartSetLibrary.items
	---@type boolean
	self.staticCursor = self.game.configModel.configs.irizz.staticCursor
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

local gfx = love.graphics

---@param i number
---@param w number
---@param h number
function NoteChartSetListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	gfx.setColor(Color.text)
	gfx.translate(15, 0)

	gfx.setFont(self.font.artist)
	gyatt.frame(item.artist or "", 0, 0, math.huge, h, "left", "top")
	gfx.setFont(self.font.title)
	gyatt.frame(item.title or "", 0, -5, math.huge, h, "left", "bottom")
end

return NoteChartSetListView
