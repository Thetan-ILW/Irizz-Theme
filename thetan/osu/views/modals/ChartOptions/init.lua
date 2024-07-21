local Modal = require("thetan.irizz.views.modals.Modal")

local ViewConfig = require("thetan.osu.views.modals.ChartOptions.ViewConfig")

---@class osu.ChartOptionsModal : Modal
---@operator call: osu.ChartOptionsModal
local ChartOptionsModal = Modal + {}

---@param game sphere.GameController
function ChartOptionsModal:new(game)
	self.game = game

	---@type osu.OsuSelectAssets?
	local assets = game.assetModel:get("osuSelect")
	assert(assets, "osu! UI not loaded")
	---@cast assets osu.OsuSelectAssets

	self.viewConfig = ViewConfig(assets)
end

return ChartOptionsModal
