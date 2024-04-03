local gyatt = require("thetan.gyatt")
local InputMap = require("thetan.gyatt.InputMap")

local GameViewInputMap = InputMap + {}

function GameViewInputMap:createBindings(gv, a)
	self.global = {
		[a.showKeybinds] = function()
			gv:openModal("thetan.irizz.views.modals.KeybindModal")
		end,
		[a.quit] = function()
			if gv:getViewName() == "gameplay" then
				return
			end
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
