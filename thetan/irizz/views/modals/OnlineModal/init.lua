local Modal = require("thetan.irizz.views.modals.Modal")

local ViewConfig = require("thetan.irizz.views.modals.OnlineModal.ViewConfig")

local OnlineModal = Modal + {}

function OnlineModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(assets)
end

return OnlineModal
