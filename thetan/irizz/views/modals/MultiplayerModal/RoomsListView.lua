local just = require("just")
local imgui = require("thetan.irizz.imgui")
local gyatt = require("thetan.gyatt")

local ListView = require("thetan.irizz.views.ListView")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textMultiplayer

local RoomsListView = ListView + {}

RoomsListView.rows = 9
RoomsListView.centerItems = false
RoomsListView.noItemsText = Text.noRooms
RoomsListView.scrollSound = Theme.sounds.scrollSoundLargeList

function RoomsListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("multiplayerModal")
end

function RoomsListView:reloadItems()
	self.items = self.game.multiplayerModel.rooms
end

function RoomsListView:drawItem(i, w, h)
	local multiplayerModel = self.game.multiplayerModel
	local item = self.items[i]
	self:drawItemBody(w, h, i, false)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.lists)
	local name = Text.room:format(item.name)

	if item.isPlaying then
		name = name .. " " .. Text.playing
	end

	local host
	for _, v in ipairs(item.users) do
		if item.host_user_id == v.id then
			host = Text.host:format(v.name)
			break
		end
	end

	just.indent(15)
	gyatt.frame(host, 0, 0, w, h, "left", "top")
	gyatt.frame(name, 0, 0, w, h, "left", "bottom")

	if multiplayerModel.room then
		return
	end

	local uiW = w / 2.5
	local uiH = Theme.imgui.size

	just.offset(w - 108)
	love.graphics.translate(0, 10)
	imgui.setSize(w, h, uiW, uiH)
	if imgui.button("joinGame" .. i, Text.join) then
		multiplayerModel.selectedRoom = item
		multiplayerModel:joinRoom("")
		just.focus()
	end
end

return RoomsListView
