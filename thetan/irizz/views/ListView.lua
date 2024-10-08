local just = require("just")
local flux = require("flux")
local class = require("class")

local gyatt = require("thetan.gyatt")
local colors = require("thetan.irizz.ui.colors")
local playSound = require("thetan.gyatt.play_sound")

---@class irizz.ListView
---@operator call: irizz.ListView
---@field scrollSound audio.Source
---@field font love.Font
---@field status string
---@field text table<string, string>
local ListView = class()

ListView.centerItems = false
ListView.targetItemIndex = 1
ListView.itemIndex = 1
ListView.visualItemIndex = 1
ListView.rows = 3

ListView.items = {}
ListView.scrollSound = nil
ListView.font = nil
ListView.staticCursor = false
ListView.status = nil

ListView.mouseScrollEase = { "quartout", 0.2 }
ListView.keyboardScrollEase = "linear"

local nextTime = 0
local maxInterval = 0.07
local pressInterval = 0.12
local acceleration = 0

local tweenTime = 0.2
local ease = "quartout"

function ListView:new(game)
	local configs = game.configModel.configs

	self.game = game
	self.config = configs.irizz

	self.actionModel = self.game.actionModel
end

function ListView:playSound()
	playSound(self.scrollSound)
end

function ListView:reloadItems()
	self.stateCounter = 1
	self.items = {}
end

---@param delta number
function ListView:scroll(delta)
	self.targetItemIndex = math.min(math.max(self.targetItemIndex + delta, 1), #self.items)
end

---@return number
function ListView:getItemIndex()
	return self.targetItemIndex
end

function ListView:drawItemBody(w, h, i, selected)
	local itemColor = (i % 2) == 1 and colors.ui.listItemEven or colors.ui.listItemOdd

	if selected and not self.staticCursor then
		itemColor = colors.ui.select
	elseif selected and not self.centerItems then
		itemColor = colors.ui.select
	end

	love.graphics.setColor(itemColor)
	love.graphics.rectangle("fill", 0, 0, w, h)
end

function ListView:autoScroll(delta, justPressed)
	local time = love.timer.getTime()

	if time < nextTime then
		return
	end

	maxInterval = self.config.scrollHoldSpeed
	pressInterval = maxInterval + self.config.scrollClickExtraTime

	local interval = maxInterval
	ease = self.keyboardScrollEase

	interval = justPressed and pressInterval or maxInterval

	nextTime = time + interval - acceleration
	tweenTime = interval
	acceleration = math.min(acceleration + 0.001, maxInterval)

	self:scroll(delta)
end

function ListView:input(w, h)
	local delta = just.wheel_over(self, just.is_over(w, h))
	if delta then
		self:scroll(-delta)
		ease = self.mouseScrollEase[1]
		tweenTime = self.mouseScrollEase[2]
		return
	end

	if not self.config.scrollAcceleration then
		acceleration = 0
	end

	local ap = self.actionModel.consumeAction
	local ad = self.actionModel.isActionDown
	local gc = self.actionModel.getCount

	if ad("up") then
		self:autoScroll(-1 * gc(), ap("up"))
	elseif ad("down") then
		self:autoScroll(1 * gc(), ap("down"))
	elseif ad("up10") then
		self:autoScroll(-10 * gc(), ap("up10"))
	elseif ad("down10") then
		self:autoScroll(10 * gc(), ap("down10"))
	elseif ap("toStart") then
		self:scroll(-math.huge)
	elseif ap("toEnd") then
		self:scroll(math.huge)
	else
		acceleration = 0
	end
end

function ListView:mouseClick(w, h, i) end

function ListView:update(w, h)
	self:input(w, h)

	local stateCounter = self.stateCounter
	if stateCounter ~= self.stateCounter then
		local itemIndex = assert(self:getItemIndex())
		self.itemIndex = itemIndex
		self.visualItemIndex = itemIndex
	end
end

---@param w number
---@param h number
function ListView:draw(w, h, update)
	if update then
		self:update(w, h)
	end

	local itemIndex = assert(self:getItemIndex())

	if self.itemIndex ~= itemIndex then
		if self.tween then
			self.tween:stop()
		end
		self.tween = flux.to(self, tweenTime, { visualItemIndex = itemIndex }):ease(ease)
		self.itemIndex = itemIndex
	end

	love.graphics.setColor(1, 1, 1, 1)

	local _h = h / self.rows
	local visualItemIndex = self.visualItemIndex

	local deltaItemIndex = math.floor(visualItemIndex) - visualItemIndex

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h)
	love.graphics.translate(0, deltaItemIndex * _h)

	for i = math.floor(visualItemIndex), self.rows + math.floor(visualItemIndex) do
		local _i = 0

		if self.centerItems then
			_i = i - math.floor(self.rows / 2)
		else
			_i = i
		end

		if update and _i < self.rows + math.floor(visualItemIndex) then
			self:mouseClick(w, _h, i)
		end

		if self.items[_i] then
			just.push()
			self:drawItem(_i, w, _h)
			just.pop()
		end
		just.emptyline(_h)
	end

	just.clip()

	if #self.items == 0 then
		love.graphics.setColor(colors.ui.text)
		love.graphics.setFont(self.font.noItems)
		local text = ""

		if self.text and self.text.noItems then
			text = self.text.noItems
		end

		gyatt.frame(self.status or text, 0, 0, w, h, "center", "center")
		return
	end

	if self.staticCursor and self.centerItems then
		love.graphics.setColor(colors.ui.select)
		love.graphics.rectangle("fill", 0, (_h * self.rows / 2) - _h / 2, w, _h)
	end
end

return ListView
