local ListView = require("thetan.irizz.views.ListView")
local TextCellImView = require("thetan.irizz.imviews.TextCellImView")
local just = require("just")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local OsuDirectChartsListView = ListView + {}

OsuDirectChartsListView.rows = 7
OsuDirectChartsListView.centerItems = true
OsuDirectChartsListView.text = Theme.textOsuDirectList

local action = {}

function OsuDirectChartsListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("osuDirectChartsListView")
	self.scrollSound = Theme.sounds.scrollSmallList

	local actionModel = self.game.actionModel
	action = actionModel:getGroup("smallList")
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
	local delta = just.wheel_over(self, just.is_over(w, h))
	if delta then
		self:scroll(-delta)
	end

	local kd = gyatt.actionDown
	local kp = gyatt.actionPressed

	if kd(action.up) then
		self:autoScroll(-1, kp(action.up))
	elseif kd(action.down) then
		self:autoScroll(1, kp(action.down))
	end
end

---@param i number
---@param w number
---@param h number
function OsuDirectChartsListView:drawItem(i, w, h)
	local item = self.items[i]
	self:drawItemBody(w, h, i, i == self:getItemIndex())

	love.graphics.setColor(Color.text)
	love.graphics.translate(0, 4)
	just.indent(15)
	TextCellImView(
		math.huge,
		h,
		"left",
		item.beatmapset.creator,
		item.version,
		self.font.creator,
		self.font.difficultyName
	)
end

return OsuDirectChartsListView
