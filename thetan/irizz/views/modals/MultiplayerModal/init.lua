local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.MultiplayerModal.ViewConfig")

local MultiplayerModal = Modal + {}

MultiplayerModal.name = "MultiplayerModal"

function MultiplayerModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(game, assets)
end

function MultiplayerModal:update()
	if self.game.multiplayerModel.room then
		self.game.gameView:closeModal()
		self.game.selectView:changeScreen("multiplayerView")
		return
	end
end

return MultiplayerModal
