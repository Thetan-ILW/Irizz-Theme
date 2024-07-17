local ListView = require("thetan.irizz.views.ListView")
local just = require("just")
local gfx_util = require("gfx_util")
local Format = require("sphere.views.Format")
local time_util = require("time_util")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local ScoreListView = ListView + {}

ScoreListView.rows = 8
ScoreListView.selectedScoreIndex = 1
ScoreListView.selectedScore = nil
ScoreListView.openResult = false
ScoreListView.oneClickOpen = true
ScoreListView.modLines = {}
ScoreListView.text = Theme.textScoreList

function ScoreListView:new(game)
	self.game = game
	self.font = Theme:getFonts("osuScoreList")
end

function ScoreListView:setAssets(assets)
	self.assets = assets
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

local gfx = love.graphics

---@param i number
---@param w number
---@param h number
function ScoreListView:drawItem(i, w, h)
	local item = self.items[i]

	local source = self.game.configModel.configs.select.scoreSourceName
	local mods = self.modLines[i]
	local username = "You"

	if source == "online" then
		username = item.user.name
	end

	gfx.setColor({ 0, 0, 0, 0.3 })
	gfx.rectangle("fill", 0, 0, w, 50)

	gfx.push()
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.translate(50, 6)

	if item.score > 9800 then
		gfx.draw(self.assets.gradeX)
	elseif item.score > 8000 then
		gfx.draw(self.assets.gradeS)
	elseif item.score > 7000 then
		gfx.draw(self.assets.gradeA)
	elseif item.score > 6000 then
		gfx.draw(self.assets.gradeB)
	elseif item.score > 5000 then
		gfx.draw(self.assets.gradeC)
	else
		gfx.draw(self.assets.gradeD)
	end

	gfx.translate(44, -5)
	gfx.setFont(self.font.username)
	gyatt.text(username)

	gfx.setFont(self.font.score)
	gyatt.text(("Score: %i"):format(item.score))
	gfx.pop()

	gfx.setFont(self.font.rightSide)
	gyatt.frame(("%s [%0.02fx]"):format(mods, item.rate), -4, 0, w, 50, "right", "top")
	gyatt.frame(("Accuracy: %0.02f"):format(item.accuracy * 1000), -4, 0, w, 50, "right", "center")

	local improvement = "-"

	if self.items[i + 1] then
		improvement = ("+%i"):format(item.score - self.items[i + 1].score)
	end

	gyatt.frame(improvement, -4, 0, w, 50, "right", "bottom")
end

return ScoreListView
