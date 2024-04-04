local ScreenView = require("sphere.views.ScreenView")

local LayersView = require("thetan.irizz.views.LayersView")

local MultiplayerView = ScreenView + {}

function MultiplayerView:load()
	self.game.selectModel:setChanged()
	self.layersView = LayersView(self.game)
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

function MultiplayerView:panels() end

function MultiplayerView:UI() end

function MultiplayerView:draw()
	self.layersView:draw(self.panels, self.UI)
end

return MultiplayerView
