local ListView = require("thetan.irizz.views.ListView")
local just = require("just")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local MountsListView = ListView + {}

MountsListView.rows = 11
MountsListView.centerItems = false
MountsListView.scrollSound = Theme.sounds.scrollSoundLargeList
MountsListView.text = Theme.textMountsList
MountsListView.selectedItemIndex = 1

function MountsListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("mountsModal")
end

function MountsListView:reloadItems()
	local locationManager = self.game.cacheModel.locationManager

	self.items = locationManager.locations
end

function MountsListView:mouseClick(w, h, i)
	local locationManager = self.game.cacheModel.locationManager

	if not just.is_over(w, h, 0, 0) then
		return
	end

	if not just.mousepressed(1) then
		return
	end

	local item = self.items[i]
	if not item then
		return
	end

	locationManager:selectLocation(item.id)
	self.selectedItemIndex = i
end

---@param i number
---@param w number
---@param h number
function MountsListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, self.selectedItemIndex == i)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.mountPaths)
	love.graphics.translate(15, 10)
	just.text(item.name, math.huge)
end

return MountsListView
