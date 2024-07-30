local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.SelectView.Settings")

local get_irizz_assets = require("thetan.irizz.assets_loader")

local SettingsModal = Modal + {}

SettingsModal.name = "Settings"

function SettingsModal:new(game)
	self.game = game

	self.viewConfig = ViewConfig(game, get_irizz_assets(game))
end

function SettingsModal:onShow()
	self.viewConfig:focused()
end

return SettingsModal
