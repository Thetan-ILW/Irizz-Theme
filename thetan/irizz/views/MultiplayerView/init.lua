local ScreenView = require("sphere.views.ScreenView")

local LayersView = require("thetan.irizz.views.LayersView")
local ViewConfig = require("thetan.irizz.views.MultiplayerView.ViewConfig")
local HeaderView = require("thetan.irizz.views.HeaderView")

local MultiplayerView = ScreenView + {}

MultiplayerView.noRoom = {
	name = "No room",
}

local viewConfig = {}
local headerView = {}

function MultiplayerView:load()
	self.game.selectModel:setChanged()
	self.layersView = LayersView(self.game)
	viewConfig = ViewConfig()
	headerView = HeaderView("multiplayer")
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
end

function MultiplayerView:leaveRoom()
	local multiplayerModel = self.game.multiplayerModel
	multiplayerModel:leaveRoom()
end

function MultiplayerView:quit()
	local multiplayerModel = self.game.multiplayerModel

	local room = multiplayerModel.room or self.noRoom

	local isHost = multiplayerModel:isHost()
	if isHost or room.isFreeNotechart then
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
