local InputMap = require("thetan.gyatt.InputMap")

local Theme = require("thetan.irizz.views.Theme")

local GameViewInputMap = InputMap + {}

local function volumeChanged(gv)
	local configs = gv.game.configModel.configs
	local settings = configs.settings
	local a = settings.audio
	local v = a.volume

	gv.showMessage("volumeChanged", v.master * 100)
end

function GameViewInputMap:createBindings(gv)
	self.global = {
		["increaseVolume"] = function()
			Theme:changeVolume(gv.game, 1)
			volumeChanged(gv)
		end,
		["decreaseVolume"] = function()
			Theme:changeVolume(gv.game, -1)
			volumeChanged(gv)
		end,
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
