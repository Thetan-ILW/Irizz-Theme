local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")

local colors = require("thetan.irizz.ui.colors")

local OsudirectListView = ListView + {}

OsudirectListView.rows = 13
OsudirectListView.centerItems = true

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function OsudirectListView:new(game, assets)
	ListView:new(game)
	self.game = game

	self.font = assets.localization.fontGroups.osuDirectListView
	self.text = assets.localization.textGroups.osuDirectListView
	self.scrollSound = assets.sounds.scrollSmallList
end

function OsudirectListView:reloadItems()
	self.items = self.game.osudirectModel.items
	self.staticCursor = self.game.configModel.configs.irizz.staticCursor

	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

---@param count number
function OsudirectListView:scroll(count)
	ListView.scroll(self, count)
	self.game.osudirectModel:setBeatmap(self.items[self.targetItemIndex])
	self:playSound()
end

local gfx = love.graphics

---@param i number
---@param w number
---@param h number
function OsudirectListView:drawItem(i, w, h)
	local item = self.items[i]
	local color = item.downloaded and colors.ui.itemDownloaded or colors.ui.text

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	gfx.translate(15, 0)

	gfx.setColor(color)
	gfx.setFont(self.font.artist)
	gyatt.frame(item.artist, 0, 0, math.huge, h, "left", "top")
	gfx.setFont(self.font.title)
	gyatt.frame(item.title, 0, -5, math.huge, h, "left", "bottom")
end

return OsudirectListView
