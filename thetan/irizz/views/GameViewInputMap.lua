local gyatt = require("thetan.gyatt")
local InputMap = require("thetan.gyatt.InputMap")

local GameViewInputMap = InputMap + {}

function GameViewInputMap:createBindings(gv, a)
	self.global = {
		[a.insertMode] = function()
			gyatt.vim.setMode(gyatt.vim.mode.insert)
		end,
		[a.normalMode] = function()
			gyatt.vim.setMode(gyatt.vim.mode.normal)
			local selectModel = gv.game.selectModel
			selectModel:debouncePullNoteChartSet()
		end,
	}
end

return GameViewInputMap
