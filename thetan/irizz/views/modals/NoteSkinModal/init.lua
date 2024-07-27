local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.NoteSkinModal.ViewConfig")

local NoteSkinModal = Modal + {}

NoteSkinModal.name = "NoteSkins"

function NoteSkinModal:onQuit()
	local note_skin = self.viewConfig.selectedNoteSkin

	if note_skin and note_skin.confg then
		note_skin.config:close()
	end
end

function NoteSkinModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(game, assets)
end

return NoteSkinModal
