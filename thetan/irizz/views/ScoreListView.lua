local ListView = require("thetan.irizz.views.ListView")
local just = require("just")
local gfx_util = require("gfx_util")
local Format = require("sphere.views.Format")
local time_util = require("time_util")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect

local ScoreListView = ListView + {}

ScoreListView.rows = 7
ScoreListView.selectedScoreIndex = 1
ScoreListView.selectedScore = nil
ScoreListView.openResult = false
ScoreListView.oneClickOpen = false
ScoreListView.noItemsText = Text.noScores
ScoreListView.modLines = {}

function ScoreListView:new(game, oneClickOpen)
	self.game = game
	self.oneClickOpen = oneClickOpen or false
	self.font = Theme:getFonts("scoreListView")
end

local modOrder = {
	{ id = 19, label = "FLN%i", format = true },
	{ id = 9, label = "NLN" },
	{ id = 20, label = "MLL%0.01f", format = true },
	{ id = 23, label = "LC%i", format = true },
	{ id = 24, label = "CH%i", format = true },
	{ id = 18, label = "BS" },
	{ id = 17, label = "RND" },
	{ id = 16, label = "MR" },
}

function ScoreListView:getModifiers(modifiers)
	if #modifiers == 0 then
		return Text.noMods
	end

	local max = 3
	local current = 0
	local modLine = ""

	for _, mod in ipairs(modOrder) do
		for _, enabledMod in ipairs(modifiers) do
			if mod.id == enabledMod.id then
				if mod.format then
					modLine = modLine .. mod.label:format(enabledMod.value)
				else
					modLine = modLine .. mod.label
				end

				modLine = modLine .. " "

				current = current + 1

				if current == max then
					return modLine
				end
			end
		end
	end

	if modLine:len() == 0 then
		modLine = Text.hasMods
	end

	return modLine
end

function ScoreListView:reloadItems()
	self.stateCounter = self.game.selectModel.scoreStateCounter

	if self.items == self.game.selectModel.scoreLibrary.items then
		return
	end

	self.items = self.game.selectModel.scoreLibrary.items
	self.modLines = {}

	for i, item in ipairs(self.items) do
		self.modLines[i] = self:getModifiers(item.modifiers)
	end

	local i = self.game.selectModel.scoreItemIndex
	self.selectedScoreIndex = i
	self.selectedScore = self.items[i]
	self.game.selectModel:scrollScore(nil, i)
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

	local source = self.game.configModel.configs.select.scoreSourceName
	local username = self.modLines[i]

	if source == "online" then
		username = item.user.name
	end

	self:drawItemBody(w, h, i, i == self.selectedScoreIndex)
	local xIndent = 10
	local yIndent = 0
	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.line1)
	gfx_util.printFrame(string.format("#%i %s", i, username), xIndent, yIndent, w, h, "left", "top")
	gfx_util.printFrame(
		string.format("[%s] %0.02fx", Format.inputMode(item.inputmode), item.rate),
		-xIndent,
		yIndent,
		w,
		h,
		"right",
		"top"
	)
	love.graphics.setFont(self.font.line2)
	gfx_util.printFrame(string.format("Score: %i", item.score), xIndent, -yIndent, w, h, "left", "bottom")
	gfx_util.printFrame(time_util.time_ago_in_words(item.time), -xIndent, -yIndent, w, h, "right", "bottom")
end

return ScoreListView
