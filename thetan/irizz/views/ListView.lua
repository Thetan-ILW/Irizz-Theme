local just = require("just")
local flux = require("flux")
local class = require("class")

local gfx_util = require("gfx_util")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

---@class sphere.irizzTheme.ListView
---@operator call: sphere.irizzTheme.ListView
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
ListView.staticCursor = Theme.misc.staticListViewCursor

function ListView:playSound()
	local configs = self.game.configModel.configs
	self.staticCursor = configs.irizz.staticCursor

	local audioSettings = configs.settings.audio
	local uiVolume = configs.irizz.uiVolume
	self.scrollSound:setVolume(audioSettings.volume.master * uiVolume)
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

function ListView:input(w, h)
	local delta = just.wheel_over(self, just.is_over(w, h))
	if delta then
		self:scroll(-delta)
	end

	local kp = just.keypressed
	if kp("left") then
		self:scroll(-1)
	elseif kp("right") then
		self:scroll(1)
	elseif kp("pageup") then
		self:scroll(-10)
	elseif kp("pagedown") then
		self:scroll(10)
	elseif kp("home") then
		self:scroll(-math.huge)
	elseif kp("end") then
		self:scroll(math.huge)
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
		self.tween = flux.to(self, 0.2, { visualItemIndex = itemIndex }):ease("quartout")
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

		if update then
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
		gfx_util.printBaseline(self.noItemsText, 0, h / 2, w, 1, "center")
		return
	end

	if self.staticCursor and self.centerItems then
		love.graphics.setColor(Color.select)
		love.graphics.rectangle("fill", 0, (_h * self.rows / 2) - _h / 2, w, _h)
	end
end

return ListView
