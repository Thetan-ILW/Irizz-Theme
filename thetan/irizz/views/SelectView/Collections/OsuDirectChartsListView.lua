local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")

local colors = require("thetan.irizz.ui.colors")

local OsuDirectChartsListView = ListView + {}

OsuDirectChartsListView.rows = 7
OsuDirectChartsListView.centerItems = true

local action = {}

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function OsuDirectChartsListView:new(game, assets)
	ListView:new(game)
	self.game = game
	self.font = assets.localization.fontGroups.osuDirectChartsListView
	self.text = assets.localization.textGroups.osuDirectListView
	self.scrollSound = assets.sounds.scrollSmallList

	self.actionModel = self.game.actionModel
end

function OsuDirectChartsListView:scroll(count)
	ListView.scroll(self, count)
	self:playSound()
end

function OsuDirectChartsListView:reloadItems()
	self.items = self.game.osudirectModel:getDifficulties()
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

function OsuDirectChartsListView:input(w, h)
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
function OsuDirectChartsListView:drawItem(i, w, h)
	local item = self.items[i]
	self:drawItemBody(w, h, i, i == self:getItemIndex())

	gfx.translate(15, 0)

	gfx.setColor(colors.ui.text)
	gfx.setFont(self.font.creator)
	gyatt.frame(item.beatmapset.creator, 0, 0, math.huge, h, "left", "top")
	gfx.setFont(self.font.difficultyName)
	gyatt.frame(item.version, 0, -5, math.huge, h, "left", "bottom")
end

return OsuDirectChartsListView
