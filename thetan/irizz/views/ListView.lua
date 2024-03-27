local just = require("just")
local flux = require("flux")
local class = require("class")

local gyatt = require("thetan.gyatt")
local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

---@class irizz.ListView
---@operator call: irizz.ListView
local ListView = class()

ListView.centerItems = false
ListView.targetItemIndex = 1
ListView.itemIndex = 1
ListView.visualItemIndex = 1
ListView.rows = 3

ListView.items = {}
ListView.scrollSound = nil
ListView.font = nil
ListView.noItemsText = "No items!"
ListView.staticCursor = false

local action = {}

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
	self.staticCursor = self.config.staticCursor

	local actionModel = self.game.actionModel
	action = actionModel:getGroup("largeList")
end

function ListView:playSound()
	if acceleration > 0.04 then
		return
	end

	self.scrollSound:stop()
	self.scrollSound:play()
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
	local itemColor = (i % 2) == 1 and Color.listItemEven or Color.listItemOdd

	if selected and not self.staticCursor then
		itemColor = Color.select
	elseif selected and not self.centerItems then
		itemColor = Color.select
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
	ease = "linear"

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
		ease = "quartout"
		tweenTime = 0.2
		return
	end

	if not self.config.scrollAcceleration then
		acceleration = 0
	end

	local ap = gyatt.actionPressed
	local ad = gyatt.actionDown
	local oc = gyatt.vim.getCount

	if ad(action.up) then
		self:autoScroll(-1 * oc(), ap(action.up))
	elseif ad(action.down) then
		self:autoScroll(1 * oc(), ap(action.down))
	elseif ad(action.up10) then
		self:autoScroll(-10 * oc(), ap(action.up10))
	elseif ad(action.down10) then
		self:autoScroll(10 * oc(), ap(action.down10))
	elseif ap(action.toStart) then
		self:scroll(-math.huge)
	elseif ap(action.toEnd) then
		self:scroll(math.huge)
	else
		acceleration = 0
	end
end

function ListView:mouseClick(w, h, i) end

function ListView:update(w, h)
	self:input(w, h)

	local stateCounter = self.stateCounter
	self:reloadItems()
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

	for i = math.floor(visualItemIndex), self.rows + math.ceil(visualItemIndex) + 1 do
		local _i = 0

		if self.centerItems then
			_i = i - math.floor(self.rows / 2)
		else
			_i = i
		end

		if update and i < self.rows + 1 then
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
		love.graphics.setColor(Color.text)
		love.graphics.setFont(self.font.noItems)
		gyatt.frame(self.noItemsText, 0, 0, w, h, "center", "center")
		return
	end

	if self.staticCursor and self.centerItems then
		love.graphics.setColor(Color.select)
		love.graphics.rectangle("fill", 0, (_h * self.rows / 2) - _h / 2, w, _h)
	end
end

return ListView
