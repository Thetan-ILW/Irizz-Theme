local just = require("just")
local gyatt = require("thetan.gyatt")

local ListView = require("thetan.irizz.views.ListView")

local colors = require("thetan.irizz.ui.colors")

local NoteSkinListView = ListView + {}

NoteSkinListView.rows = 11
NoteSkinListView.centerItems = false
NoteSkinListView.selectedNoteSkin = nil
NoteSkinListView.inputMode = ""

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function NoteSkinListView:new(game, assets)
	ListView:new(game)
	self.game = game

	self.text, self.font = assets.localization:get("noteSkinsModal")
	assert(self.font)
end

function NoteSkinListView:reloadItems()
	self.inputMode = tostring(self.game.selectController.state.inputMode)

	if self.inputMode == "" then
		self.items = {}
		self.selectedNoteSkin = nil
		return
	end

	self.items = self.game.noteSkinModel:getSkinInfos(self.inputMode)
	self.selectedNoteSkin = self.game.noteSkinModel:getNoteSkin(self.inputMode)
end

function NoteSkinListView:drawItem(i, w, h)
	local item = self.items[i]

	local changed, active, hovered = just.button("noteskin" .. i, just.is_over(w, h))
	if changed then
		self.game.noteSkinModel:setDefaultNoteSkin(self.inputMode, item:getPath())
	end

	if self.items[i].name == self.selectedNoteSkin.name then
		love.graphics.setColor(colors.ui.select)
		love.graphics.rectangle("fill", 0, 0, w, h)
	else
		self:drawItemBody(w, h, i, hovered)
	end

	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(self.font.noteSkinName)
	gyatt.frame(item.name, 15, 0, math.huge, h, "left", "center")
end

return NoteSkinListView
