local ScreenView = require("sphere.views.ScreenView")

local MultiplayerView = ScreenView + {}

function MultiplayerView:load()
	self.game.selectModel:setChanged()
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
end

function MultiplayerView:draw() end

return MultiplayerView
