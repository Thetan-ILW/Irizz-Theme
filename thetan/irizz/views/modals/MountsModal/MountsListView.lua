local ListView = require("thetan.irizz.views.ListView")
local just = require("just")

local colors = require("thetan.irizz.ui.colors")

local MountsListView = ListView + {}

MountsListView.rows = 11
MountsListView.centerItems = false
MountsListView.selectedItemIndex = 1

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function MountsListView:new(game, assets)
	ListView:new(game)
	self.game = game
	self.text, self.font = assets.localization:get("mountsList")
	assert(self.text, self.font)
end

function MountsListView:reloadItems()
	local locationManager = self.game.cacheModel.locationManager

	self.items = locationManager.locations

	for i, v in ipairs(self.items) do
		if v.id == locationManager.selected_id then
			self.selectedItemIndex = i
		end
	end
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

	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(self.font.mountPaths)
	love.graphics.translate(15, 10)
	just.text(item.name, math.huge)
end

return MountsListView
