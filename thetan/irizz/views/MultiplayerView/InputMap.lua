local InputMap = require("thetan.gyatt.InputMap")

local MultiplayerInputMap = InputMap + {}

function MultiplayerInputMap:createBindings(mv)
	local gameView = mv.game.gameView

	self.modals = {
		["showMods"] = function()
			if mv.room.isFreeNotechart or mv.isHost then
				gameView:openModal("thetan.irizz.views.modals.ModifierModal")
			end
		end,
		["showSkins"] = function()
			gameView:openModal("thetan.irizz.views.modals.NoteSkinModal")
		end,
		["showInputs"] = function()
			gameView:openModal("thetan.irizz.views.modals.InputModal")
		end,
	}
end

return MultiplayerInputMap
