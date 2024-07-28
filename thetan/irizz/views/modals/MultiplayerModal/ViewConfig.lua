local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")
local just = require("just")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local Layout = require("thetan.irizz.views.modals.MultiplayerModal.Layout")
local Container = require("thetan.gyatt.Container")
local RoomsListView = require("thetan.irizz.views.modals.MultiplayerModal.RoomsListView")
local TextBox = require("thetan.irizz.imgui.TextBox")

local ViewConfig = IViewConfig + {}

local gfx = love.graphics
local roomName = ""
local roomPassword = ""
local password = ""

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ViewConfig:new(game, assets)
	self.playersContainer = Container("playersContainer")
	self.roomsListView = RoomsListView(game, assets)

	text, font = assets.localization:get("multiplayerModal")
	assert(text and font)
end

function ViewConfig:players(view)
	local w, h = Layout:move("players")

	local users = view.game.multiplayerModel.users

	local heightStart = just.height

	ui:panel(w, h)

	self.playersContainer:startDraw(w, h)

	gfx.setColor(colors.ui.text)
	gfx.setFont(font.listHeader)

	gyatt.text(text.players)
	just.next(0, 5)

	gfx.setFont(font.lists)

	if users then
		for _, user in ipairs(users) do
			gyatt.text(user.name)
		end
	end

	self.playersContainer.scrollLimit = just.height - heightStart - h
	self.playersContainer.stopDraw()

	w, h = Layout:move("players")
	ui:border(w, h)
end

function ViewConfig:rooms(view)
	local w, h = Layout:move("rooms")

	ui:panel(w, h)
	self.roomsListView:draw(w, h, true)
	ui:border(w, h)
end

function ViewConfig:buttons(view)
	local w, h = Layout:move("buttons")

	ui:border(w, h)
	ui:panel(w, h)

	gfx.setColor(colors.ui.text)
	gfx.setFont(font.buttons)

	w = w - 20
	h = h - 20
	gfx.translate(10, 5)

	gyatt.frame(text.createRoom, 0, 0, w, h, "center", "top")
	gfx.translate(0, font.buttons:getHeight() * gyatt.getTextScale() + 15)
	local changed, input = TextBox("roomName", { roomName, text.name }, nil, w, h, false)

	if changed == "text" then
		roomName = input
	end

	changed, input = TextBox("roomPassword", { roomPassword, text.password }, nil, w, h, true)

	if changed == "text" then
		roomPassword = input
	end

	local uiW = w / 2.5
	local uiH = 50

	imgui.setSize(w, h, uiW, uiH)

	local textW = font.buttons:getWidth(text.create) * gyatt.getTextScale()
	gfx.translate((w / 2) - (textW + 50) / 2, 10)

	if imgui.button("createRoom", text.create) then
		view.game.multiplayerModel:createRoom(roomName, roomPassword)
		roomName = ""
		roomPassword = ""
	end
end

function ViewConfig:joinGame(view, room)
	local multiModel = view.game.multiplayerModel

	local w, h = Layout:move("connectScreen")
	gfx.setColor(colors.ui.text)
	gfx.setFont(font.listHeader)
	gyatt.frame(text.enterPassword:format(room.name), 0, 0, w, h, "center", "top")

	local gap = 20
	local button1Size = gfx.getFont():getWidth(text.back)
	local button2Size = gfx.getFont():getWidth(text.join)

	gfx.setColor(colors.ui.text)
	gfx.setFont(font.buttons)

	gfx.translate(0, 80)
	local changed, input = TextBox("password", { password, text.password }, nil, w, h, true)

	if changed == "text" then
		password = input
	end

	gfx.translate(w / 2 - (button1Size + button2Size), 50)

	if imgui.button("backToRooms", text.back) then
		multiModel.selectedRoom = nil
		just.focus()
	end

	just.sameline()
	gfx.translate(gap, 0)

	if imgui.button("connectToRoom", text.join) then
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
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.title)
	gyatt.frame(text.title, 0, 0, w, h, "center", "center")

	local status = multiModel.status
	if status ~= "connected" then
		w, h = Layout:move("base")
		gfx.setFont(font.noItems)
		gyatt.frame(text.notConnected:format(status), 0, 0, w, h, "center", "center")
		return
	end

	self:players(view)
	self:rooms(view)
	self:buttons(view)
end

return ViewConfig
