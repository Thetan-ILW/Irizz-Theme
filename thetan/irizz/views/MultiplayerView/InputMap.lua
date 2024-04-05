local InputMap = require("thetan.gyatt.InputMap")

local MultiplayerInputMap = InputMap + {}

function MultiplayerInputMap:createBindings(mv, a)
	local gameView = mv.game.gameView

	self.modals = {
		[a.showMods] = function()
			if mv.room.isFreeNotechart or mv.isHost then
				gameView:openModal("thetan.irizz.views.modals.ModifierModal")
			end
		end,
		[a.showSkins] = function()
			gameView:openModal("thetan.irizz.views.modals.NoteSkinModal")
		end,
		[a.showInputs] = function()
			gameView:openModal("thetan.irizz.views.modals.InputModal")
		end,
	}
end

return MultiplayerInputMap
