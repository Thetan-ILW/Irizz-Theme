local Modal = require("thetan.iris.views.modals.Modal")
local ViewConfig = require("thetan.iris.views.modals.ModifierModal.ViewConfig")
local AvailableModifierListView = require("thetan.iris.views.modals.ModifierModal.AvailableModifierListView")
local ModifierListView = require("thetan.iris.views.modals.ModifierModal.ModifierListView")

local ModifierModal = Modal + {}

ModifierModal.name = "Modifiers"
ModifierModal.viewConfig = ViewConfig

function ModifierModal:new(game)
	self.game = game

	AvailableModifierListView.game = game
	ModifierListView.game = game
	self.viewConfig.availableModifierListView = AvailableModifierListView(game)
	self.viewConfig.modifierListView = ModifierListView(game)
end

return ModifierModal
