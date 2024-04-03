local gyatt = require("thetan.gyatt")
local InputMap = require("thetan.gyatt.InputMap")

local GameViewInputMap = InputMap + {}

function GameViewInputMap:createBindings(gv, a)
	self.global = {
		[a.showKeybinds] = function()
			gv:openModal("thetan.irizz.views.modals.KeybindModal")
		end,
		[a.showChartInfo] = function()
			gv:openModal("thetan.irizz.views.modals.ChartInfoModal")
		end,
		[a.quit] = function()
			gv:sendQuitSignal()
		end,
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
