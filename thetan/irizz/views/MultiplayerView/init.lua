local ScreenView = require("sphere.views.ScreenView")

local LayersView = require("thetan.irizz.views.LayersView")
local ViewConfig = require("thetan.irizz.views.MultiplayerView.ViewConfig")
local HeaderView = require("thetan.irizz.views.HeaderView")

local InputMap = require("thetan.irizz.views.MultiplayerView.InputMap")

local MultiplayerView = ScreenView + {}

MultiplayerView.noRoom = {
	name = "No room",
}

MultiplayerView.isHost = false
MultiplayerView.room = MultiplayerView.noRoom

local viewConfig = {}
local headerView = {}
local inputMap = {}

function MultiplayerView:load()
	self.game.selectModel:setChanged()
	self.layersView = LayersView(self.game)
	viewConfig = ViewConfig()
	headerView = HeaderView("multiplayer")

	local actionModel = self.game.actionModel
	inputMap = InputMap(self, actionModel:getGroup("songSelect"))
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
	self.isHost = multiplayerModel:isHost()
end

function MultiplayerView:receive(event)
	if event.name == "keypressed" then
		if inputMap:call("modals") then
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
	local function panels() end

	local function UI()
		headerView:draw(self)
		viewConfig:draw(self)
	end

	self.layersView:draw(panels, UI)
end

return MultiplayerView
