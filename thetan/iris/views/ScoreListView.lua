local ListView = require("thetan.iris.views.ListView")
local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local Format = require("sphere.views.Format")
local time_util = require("time_util")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect

local ScoreListView = ListView + {}

ScoreListView.rows = 7
ScoreListView.selectedScoreIndex = 1
ScoreListView.selectedScore = nil
ScoreListView.openResult = false
ScoreListView.oneClickOpen = false
ScoreListView.noItemsText = Text.noScores

function ScoreListView:new(game, oneClickOpen)
	self.game = game
	self.oneClickOpen = oneClickOpen or false
	self.font = Theme:getFonts("scoreListView")
end

function ScoreListView:reloadItems()
	self.stateCounter = self.game.selectModel.scoreStateCounter

	if self.items == self.game.scoreLibraryModel.items then
		return
	end

	self.items = self.game.scoreLibraryModel.items

	if #self.items == 0 then
		self.selectedScoreIndex = 1
		self.selectedScore = self.items[1]
		self.game.selectModel:scrollScore(nil, 1)
		return
	end
end

function ScoreListView:mouseClick(w, h, i)
	if just.is_over(w, h, 0, 0) then
		if just.mousepressed(1) then
			if self.selectedScoreIndex == i then
				self.openResult = true
				return
			end

			self.selectedScoreIndex = i
			self.selectedScore = self.items[i]
			self.game.selectModel:scrollScore(nil, i)

			if self.oneClickOpen then
				self.openResult = true
				return
			end
		end
	end
end

---@param i number
---@param w number
---@param h number
function ScoreListView:drawItem(i, w, h)
	local item = self.items[i]

	local scoreSourceName = self.game.scoreLibraryModel.scoreSourceName
	local username = Text.you

	if scoreSourceName == "online" then
		username = item.user.name
	end

	self:drawItemBody(w, h, i, i == self.selectedScoreIndex)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.line1)
	just.indent(10)
	just.text(string.format("#%i %s", i, username), w)
	just.sameline()
	just.offset(0)
	just.indent(-10)
	just.text(string.format("[%s] %0.02fx", Format.inputMode(item.inputmode), item.rate), w, true)
	just.indent(10)
	love.graphics.setFont(self.font.line2)
	just.text(string.format("Score: %i", item.score), w)
	just.sameline()
	just.offset(0)
	just.indent(-10)
	just.text(time_util.time_ago_in_words(item.time), w, true)
end

return ScoreListView
