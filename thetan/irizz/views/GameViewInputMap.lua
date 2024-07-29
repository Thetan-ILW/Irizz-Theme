local InputMap = require("thetan.gyatt.InputMap")

local GameViewInputMap = InputMap + {}

function GameViewInputMap:createBindings(gv)
	self.global = {
		["insertMode"] = function()
			self.actionModel.setVimMode("Insert")
		end,
		["normalMode"] = function()
			self.actionModel.setVimMode("Normal")
			local selectModel = gv.game.selectModel
			selectModel:debouncePullNoteChartSet()
		end,
	}
end

return GameViewInputMap
