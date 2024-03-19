local Modal = require("thetan.irizz.views.modals.Modal")

local flux = require("flux")
local ViewConfig = require("thetan.irizz.views.modals.MountsModal.ViewConfig")
local MountsListView = require("thetan.irizz.views.modals.MountsModal.MountsListView")

local MountsModal = Modal + {}

MountsModal.viewConfig = ViewConfig

function MountsModal:hide()
	if self.game.cacheModel.isProcessing then
		return
	end

    self:onHide()

    if self.showTween then
        self.showTween:stop()
        self.showTween = nil
    end

    self.hideTween = flux.to(self, 0.44, {alpha = -1}):ease("quadout")
end

function MountsModal:new(game)
    self.game = game
    self.viewConfig.mountsListView = MountsListView(game)
end

return MountsModal
