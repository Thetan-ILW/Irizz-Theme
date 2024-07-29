local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")
local Format = require("sphere.views.Format")
local time_util = require("time_util")

local colors = require("thetan.irizz.ui.colors")

---@class irizz.ScoreListView : irizz.ListView
---@operator call: irizz.ScoreListView
local ScoreListView = ListView + {}

ScoreListView.rows = 7
ScoreListView.selectedScoreIndex = 1
ScoreListView.selectedScore = nil
ScoreListView.openResult = false
ScoreListView.oneClickOpen = false
ScoreListView.modLines = {}

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
---@param oneClickOpen boolean
function ScoreListView:new(game, assets, oneClickOpen)
	self.game = game
	self.oneClickOpen = oneClickOpen or false
	self.font = assets.localization.fontGroups.scoreListView
	self.text = assets.localization.textGroups.scoreListView
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
		return self.text.noMods
	end

	local max = 3
	local current = 0
	local modLine = ""

	for _, mod in ipairs(modOrder) do
		for _, enabledMod in ipairs(modifiers) do
			if mod.id == enabledMod.id then
				if mod.format and type(enabledMod.value) == "number" then
					modLine = modLine .. mod.label:format(enabledMod.value)
				elseif mod.format and type(enabledMod.value) == "string" then
					modLine = modLine .. mod.label:format(0)
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
		modLine = self.text.hasMods
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

function ScoreListView:scrollScore(delta)
	local i = self.selectedScoreIndex + delta
	local score = self.items[i]

	if not score then
		return
	end

	self:scroll(delta)
	self.selectedScore = score
	self.selectedScoreIndex = i
	self.game.selectModel:scrollScore(nil, i)
	self.openResult = true
end

function ScoreListView:mouseClick(w, h, i)
	if gyatt.isOver(w, h, 0, 0) then
		if gyatt.mousePressed(1) then
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
	local delta = gyatt.wheelOver(self, gyatt.isOver(w, h))

	if delta then
		self:scroll(-delta)
		return
	end
end

local gfx = love.graphics

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

	gfx.setColor(colors.ui.text)

	gfx.setFont(self.font.line1)
	gfx.translate(10, 0)
	gyatt.frame(("#%i %s"):format(i, username), 0, 0, w, h, "left", "top")
	gfx.translate(-20, 0)
	gyatt.frame(("[%s] %0.02fx"):format(Format.inputMode(item.inputmode), item.rate), 0, 0, w, h, "right", "top")

	gfx.setFont(self.font.line2)
	gfx.translate(20, 0)
	gyatt.frame(("Score: %i"):format(item.score), 0, 0, w, h, "left", "bottom")
	gfx.translate(-20, 0)
	gyatt.frame(time_util.time_ago_in_words(item.time), 0, 0, w, h, "right", "bottom")
end

return ScoreListView
