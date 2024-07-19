local class = require("class")

local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")
local just = require("just")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textMultiplayer
local Font = Theme:getFonts("multiplayerModal")
local cfg = Theme.imgui

local Layout = require("thetan.irizz.views.modals.MultiplayerModal.Layout")
local Container = require("thetan.gyatt.Container")
local RoomsListView = require("thetan.irizz.views.modals.MultiplayerModal.RoomsListView")
local TextBox = require("thetan.irizz.imgui.TextBox")

local ViewConfig = class()

local gfx = love.graphics
local roomName = ""
local roomPassword = ""
local password = ""

function ViewConfig:new(game)
	self.playersContainer = Container("playersContainer")
	self.roomsListView = RoomsListView(game)
end

function ViewConfig:players(view)
	local w, h = Layout:move("players")

	local users = view.game.multiplayerModel.users

	local heightStart = just.height

	Theme:panel(w, h)

	self.playersContainer:startDraw(w, h)

	gfx.setColor(Color.text)
	gfx.setFont(Font.listHeader)

	just.text(Text.players)
	just.next(0, 5)

	gfx.setFont(Font.lists)

	if users then
		for _, user in ipairs(users) do
			just.text(user.name)
		end
	end

	self.playersContainer.scrollLimit = just.height - heightStart - h
	self.playersContainer.stopDraw()

	w, h = Layout:move("players")
	Theme:border(w, h)
end

function ViewConfig:rooms(view)
	local w, h = Layout:move("rooms")

	Theme:panel(w, h)
	self.roomsListView:draw(w, h, true)
	Theme:border(w, h)
end

function ViewConfig:buttons(view)
	local w, h = Layout:move("buttons")

	Theme:border(w, h)
	Theme:panel(w, h)

	gfx.setColor(Color.text)
	gfx.setFont(Font.buttons)

	w = w - 20
	h = h - 20
	gfx.translate(10, 5)

	gfx_util.printFrame(Text.createRoom, 0, 0, w, h, "center", "top")
	gfx.translate(0, Font.buttons:getHeight() + 15)
	local changed, text = TextBox("roomName", { roomName, Text.name }, nil, w, h, false)

	if changed == "text" then
		roomName = text
	end

	changed, text = TextBox("roomPassword", { roomPassword, Text.password }, nil, w, h, true)

	if changed == "text" then
		roomPassword = text
	end

	local uiW = w / 2.5
	local uiH = cfg.size

	imgui.setSize(w, h, uiW, uiH)

	local textW = Font.buttons:getWidth(Text.create)
	gfx.translate((w / 2) - (textW + Theme.imgui.size) / 2, 10)

	if imgui.button("createRoom", Text.create) then
		view.game.multiplayerModel:createRoom(roomName, roomPassword)
		roomName = ""
		roomPassword = ""
	end
end

function ViewConfig:joinGame(view, room)
	local multiModel = view.game.multiplayerModel

	local w, h = Layout:move("connectScreen")
	gfx.setColor(Color.text)
	gfx.setFont(Font.listHeader)
	gfx_util.printFrame(Text.enterPassword:format(room.name), 0, 0, w, h, "center", "top")

	local imguiSize = Theme.imgui.size
	local nextItemOffset = Theme.imgui.nextItemOffset

	local gap = 20
	local button1Size = gfx.getFont():getWidth(Text.back)
	local button2Size = gfx.getFont():getWidth(Text.join)

	gfx.setColor(Color.text)
	gfx.setFont(Font.buttons)

	gfx.translate(0, 80)
	local changed, text = TextBox("password", { password, Text.password }, nil, w, h, true)

	if changed == "text" then
		password = text
	end

	gfx.translate(w / 2 - (button1Size + button2Size), 50)

	if imgui.button("backToRooms", Text.back) then
		multiModel.selectedRoom = nil
		just.focus()
	end

	just.sameline()
	gfx.translate(gap, 0)

	if imgui.button("connectToRoom", Text.join) then
		multiModel:joinRoom(password)
	end
end

function ViewConfig:draw(view)
	Layout:draw()

	self.roomsListView:reloadItems()

	local multiModel = view.game.multiplayerModel
	local room = multiModel.room
	local selectedRoom = multiModel.selectedRoom

	if selectedRoom and not room then
		self:joinGame(view, selectedRoom)
		return
	end

	local w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.title, 0, 0, w, h, "center", "center")

	local status = multiModel.status
	if status ~= "connected" then
		w, h = Layout:move("base")
		gfx.setFont(Font.noItems)
		gfx_util.printFrame(Text.notConnected:format(status), 0, 0, w, h, "center", "center")
		return
	end

	self:players(view)
	self:rooms(view)
	self:buttons(view)
end

return ViewConfig
