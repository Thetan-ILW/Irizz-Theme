local Modal = require("thetan.irizz.views.modals.Modal")

local flux = require("flux")
local ViewConfig = require("thetan.irizz.views.modals.MountsModal.ViewConfig")

local MountsModal = Modal + {}

function MountsModal:onHide()
	local configs = self.game.configModel.configs
	local settings = configs.settings
	local ss = settings.select

	self.game.selectModel.collectionLibrary:load(ss.locations_in_collections)
end

function MountsModal:hide()
	if self.game.cacheModel.isProcessing then
		return
	end

	self:onHide()

	if self.showTween then
		self.showTween:stop()
		self.showTween = nil
	end

	self.hideTween = flux.to(self, 0.44, { alpha = -1 }):ease("quadout")
end

function MountsModal:new(game)
	self.game = game

	local assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(game, assets)
end

return MountsModal
