local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.SelectView.Settings")
local IrizzAssets = require("thetan.irizz.views.IrizzAssets")

local SettingsModal = Modal + {}

SettingsModal.name = "Settings"

function SettingsModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")

	if not assets then
		assets = IrizzAssets()
		game.assetModel:store("irizz", assets)
	end

	self.viewConfig = ViewConfig(game, assets)
end

return SettingsModal
