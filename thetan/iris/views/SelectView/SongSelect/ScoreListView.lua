local ListView = require("thetan.iris.views.ListView")
local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local Format = require("sphere.views.Format")
local time_util = require("time_util")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect
local font

local ScoreListView = ListView + {}

ScoreListView.rows = 7
ScoreListView.selectedScoreIndex = 0
ScoreListView.selectedScore = nil
ScoreListView.openResult = false
ScoreListView.noItemsText = Text.noScores

function ScoreListView:new(game)
	self:crap(game)
	font = Theme:getFonts("scoreListView")
end

function ScoreListView:reloadItems()
	self.stateCounter = self.game.selectModel.scoreStateCounter

	if (self.items == self.game.scoreLibraryModel.items) then
		return
	end

	self.items = self.game.scoreLibraryModel.items

	if #self.items ~= 0 then
		self.selectedScoreIndex = 1
		self.selectedScore = self.items[1]
		self.game.selectModel:scrollScore(nil, 1)
		return
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

	if just.is_over(w, h, 0, 0) then
		if just.mousepressed(1) then
			if self.selectedScoreIndex == i then
				self.openResult = true
				return
			end

			self.selectedScoreIndex = i
			self.selectedScore = item
			self.game.selectModel:scrollScore(nil, i)
		end
	end

	self:drawItemBody(w, h, i, i == self.selectedScoreIndex)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.line1)

	love.graphics.translate(0, 0)
	just.indent(10)
	just.text(string.format("#%i %s", i, username), w)
	just.sameline()
	just.offset(0)
	just.indent(-10)
	just.text(string.format("[%s] %0.02fx", Format.inputMode(item.inputmode), item.rate), w, true)
	just.indent(10)
	love.graphics.setFont(font.line2)
	just.text(string.format("Score: %i",item.score), w)
	just.sameline()
	just.offset(0)
	just.indent(-10)
	just.text(time_util.time_ago_in_words(item.time), w, true)
end

return ScoreListView

