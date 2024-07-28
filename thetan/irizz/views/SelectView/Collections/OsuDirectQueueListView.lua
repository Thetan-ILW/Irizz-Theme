local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")

local colors = require("thetan.irizz.ui.colors")

local OsudirectProcessingListView = ListView + {}

OsudirectProcessingListView.rows = 11
OsudirectProcessingListView.centerItems = false

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function OsudirectProcessingListView:new(game, assets)
	ListView:new(game)
	self.game = game

	self.font = assets.localization.fontGroups.osuDirectQueueListView
	self.text = assets.localization.textGroups.osuDirectListView
	self.scrollSound = assets.sounds.scrollSmallList
end

function OsudirectProcessingListView:reloadItems()
	self.items = self.game.osudirectModel.processing
end

function OsudirectProcessingListView:input() end

local gfx = love.graphics

---@param i number
---@param w number
---@param h number
function OsudirectProcessingListView:drawItem(i, w, h)
	local item = self.items[i]

	self:drawItemBody(w, h, i, i == self:getItemIndex())

	gfx.setColor(colors.ui.text)
	gfx.setFont(self.font.status)

	if item.status then
		gyatt.frame(item.status, -15, 0, w, h, "right", "top")
	end

	gfx.translate(15, 0)

	gfx.setFont(self.font.artist)
	gyatt.frame(item.artist, 0, 0, math.huge, h, "left", "top")
	gfx.setFont(self.font.title)
	gyatt.frame(item.title, 0, -5, math.huge, h, "left", "bottom")
end

return OsudirectProcessingListView
