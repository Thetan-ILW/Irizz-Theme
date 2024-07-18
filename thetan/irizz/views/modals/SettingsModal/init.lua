local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.SelectView.Settings")

local SettingsModal = Modal + {}

SettingsModal.name = "Settings"

function SettingsModal:new(game)
	self.game = game
	self.viewConfig = ViewConfig(game)
end

return SettingsModal
