local ScreenView = require("sphere.views.ScreenView")

local LayersView = require("thetan.irizz.views.LayersView")
local ViewConfig = require("thetan.irizz.views.MultiplayerView.ViewConfig")
local Layout = require("thetan.irizz.views.MultiplayerView.Layout")
local HeaderView = require("thetan.irizz.views.HeaderView")

local InputMap = require("thetan.irizz.views.MultiplayerView.InputMap")

local MultiplayerView = ScreenView + {}

MultiplayerView.noRoom = {
	name = "No room",
}

MultiplayerView.isHost = false
MultiplayerView.room = MultiplayerView.noRoom
MultiplayerView.users = nil
MultiplayerView.messages = nil

local viewConfig = {}
local headerView = {}

function MultiplayerView:load()
	self.game.selectModel:setChanged()
	local actionModel = self.game.actionModel

	self.layersView = LayersView(self.game, "select", "preview")
	viewConfig = ViewConfig(self.game, actionModel)
	headerView = HeaderView(self.game, "multiplayer")

	self.inputMap = InputMap(self, actionModel)
end

---@param dt number
function MultiplayerView:update(dt)
	self.game.selectController:update()

	local multiplayerModel = self.game.multiplayerModel
	if not multiplayerModel.room then
		self:changeScreen("selectView")
	elseif multiplayerModel.isPlaying then
		self:changeScreen("gameplayView")
	end

	self.layersView:update()

	self.room = multiplayerModel.room or self.noRoom
	self.users = multiplayerModel.roomUsers or {}
	self.isHost = multiplayerModel:isHost()
	self.messages = multiplayerModel.roomMessages
end

function MultiplayerView:receive(event)
	if event.name == "keypressed" then
		if self.inputMap:call("modals") then
			return
		end
	end
end

function MultiplayerView:leaveRoom()
	local multiplayerModel = self.game.multiplayerModel
	multiplayerModel:leaveRoom()
end

function MultiplayerView:quit()
	if self.isHost or self.room.isFreeNotechart then
		self:changeScreen("selectView")
	end
end

function MultiplayerView:draw()
	Layout:draw()

	local function panels()
		viewConfig.panels()
	end

	local function UI()
		headerView:draw(self)
		viewConfig:draw(self)
	end

	self.layersView:draw(panels, UI)
end

return MultiplayerView
