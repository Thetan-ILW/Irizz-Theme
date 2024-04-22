local ListView = require("thetan.irizz.views.ListView")
local just = require("just")
local gfx_util = require("gfx_util")
local Format = require("sphere.views.Format")
local time_util = require("time_util")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local ScoreListView = ListView + {}

ScoreListView.rows = 7
ScoreListView.selectedScoreIndex = 1
ScoreListView.selectedScore = nil
ScoreListView.openResult = false
ScoreListView.oneClickOpen = false
ScoreListView.modLines = {}
ScoreListView.text = Theme.textScoreList

function ScoreListView:new(game, oneClickOpen)
	self.game = game
	self.oneClickOpen = oneClickOpen or false
	self.font = Theme:getFonts("scoreListView")
end

function ScoreListView:reloadItems()
	self.stateCounter = self.game.selectModel.scoreStateCounter
	local chartview = self.game.selectModel.chartview

	if not chartview then
		return
	end

	self.inputMode = chartview.inputmode
	local status, items = self.game.osuApi:getScores(chartview.osu_beatmap_id)

	self.status = status

	if self.items ~= items then
		self.items = items
		self.selectedItemIndex = 1
	end
end

function ScoreListView:mouseClick(w, h, i)
	if just.is_over(w, h, 0, 0) then
		if just.mousepressed(1) then
			self.selectedItemIndex = i
		end
	end
end

function ScoreListView:input(w, h)
	local delta = just.wheel_over(self, just.is_over(w, h))
	if delta then
		self:scroll(-delta)
		return
	end
end

---@param i number
---@param w number
---@param h number
function ScoreListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, i == self.selectedItemIndex)
	local xIndent = 10
	local yIndent = 0
	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.line1)
	gfx_util.printFrame(string.format("#%i %s", i, item.username), xIndent, yIndent, w, h, "left", "top")
	gfx_util.printFrame(
		string.format("[%s] %0.02fx", Format.inputMode(self.inputMode), item.time_rate),
		-xIndent,
		yIndent,
		w,
		h,
		"right",
		"top"
	)
	love.graphics.setFont(self.font.line2)
	gfx_util.printFrame(
		string.format("Accuracy: %0.02f%%", item.accuracy * 100),
		xIndent,
		-yIndent,
		w,
		h,
		"left",
		"bottom"
	)

	--gfx_util.printFrame(time_util.time_ago_in_words(item.time), -xIndent, -yIndent, w, h, "right", "bottom")
end

return ScoreListView
