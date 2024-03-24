local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.MultiplayerModal.ViewConfig")

local MultiplayerModal = Modal + {}

MultiplayerModal.name = "MultiplayerModal"
MultiplayerModal.viewConfig = nil

function MultiplayerModal:new(game)
    self.game = game
    self.viewConfig = ViewConfig(game)
end

function MultiplayerModal:update()
	if self.game.multiplayerModel.room then
		self.game.gameView:closeModal()
		self.game.selectView:changeScreen("multiplayerView")
		return
	end
end

return MultiplayerModal
