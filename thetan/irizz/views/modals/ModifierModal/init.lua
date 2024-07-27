local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.ModifierModal.ViewConfig")
local AvailableModifierListView = require("thetan.irizz.views.modals.ModifierModal.AvailableModifierListView")
local ModifierListView = require("thetan.irizz.views.modals.ModifierModal.ModifierListView")

local ModifierModal = Modal + {}

ModifierModal.name = "Modifiers"

function ModifierModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(assets)

	AvailableModifierListView.game = game
	ModifierListView.game = game
	self.viewConfig.availableModifierListView = AvailableModifierListView(game, assets)
	self.viewConfig.modifierListView = ModifierListView(game, assets)
end

return ModifierModal
