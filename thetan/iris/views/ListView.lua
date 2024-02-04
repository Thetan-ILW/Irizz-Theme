local just = require("just")
local flux = require("flux")
local class = require("class")

local gfx_util = require("gfx_util")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors

---@class sphere.IrisTheme.ListView
---@operator call: sphere.IrisTheme.ListView
local ListView = class()

ListView.centerItems = false
ListView.targetItemIndex = 1
ListView.itemIndex = 1
ListView.visualItemIndex = 1
ListView.rows = 3

ListView.scrollSound = nil
ListView.font = nil
ListView.noItemsText = "No items!"

function ListView:playSound()
	local audioSettings = self.game.configModel.configs.settings.audio
	self.scrollSound:setVolume(audioSettings.volume.master * Theme.sounds.ui)
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

	if selected then
		itemColor = Color.select
	end

	love.graphics.setColor(itemColor)
	love.graphics.rectangle("fill", 0, 0, w, h)
end

---@param w number
---@param h number
function ListView:draw(w, h)
	local itemIndex = assert(self:getItemIndex())

	if self.itemIndex ~= itemIndex then
		if self.tween then
			self.tween:stop()
		end
		self.tween = flux.to(self, 0.2, {visualItemIndex = itemIndex}):ease("quartout")
		self.itemIndex = itemIndex
	end

	local stateCounter = self.stateCounter
	self:reloadItems()
	if stateCounter ~= self.stateCounter then
		local itemIndex = assert(self:getItemIndex())
		self.itemIndex = itemIndex
		self.visualItemIndex = itemIndex
	end

	love.graphics.setColor(1, 1, 1, 1)

	local _h = h / self.rows
	local visualItemIndex = self.visualItemIndex

	local deltaItemIndex = math.floor(visualItemIndex) - visualItemIndex

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h)

	if self.centerItems then
		love.graphics.translate(0, deltaItemIndex * _h)
	else
		love.graphics.translate(0, (deltaItemIndex * _h) - (math.floor(self.rows / 2) * _h))
	end

	local delta = just.wheel_over(self, just.is_over(w, h))
	if delta then
		self:scroll(-delta)
	end

	for i = math.floor(visualItemIndex), self.rows + math.ceil(visualItemIndex) + 1 do
		local _i = i - math.floor(self.rows / 2)
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
		gfx_util.printBaseline(self.noItemsText, 0, h/2, w, 1, "center")
	end
end

return ListView
