local just = require("just")
local gfx_util = require("gfx_util")

local ListView = require("thetan.irizz.views.ListView")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textNoteSkins

local NoteSkinListView = ListView + {}

NoteSkinListView.rows = 11
NoteSkinListView.centerItems = false
NoteSkinListView.noItemsText = Text.noSettings
NoteSkinListView.scrollSound = Theme.sounds.scrollSoundLargeList
NoteSkinListView.selectedNoteSkin = nil
NoteSkinListView.inputMode = ""

function NoteSkinListView:new(game)
	self.game = game
	self.font = Theme:getFonts("noteSkinModal")
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
		love.graphics.setColor(Color.select)
		love.graphics.rectangle("fill", 0, 0, w, h)
	else
		self:drawItemBody(w, h, i, hovered)
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.noteSkinName)
	gfx_util.printFrame(item.name, 15, 0, w - 44, h, "left", "center")
end

return NoteSkinListView

