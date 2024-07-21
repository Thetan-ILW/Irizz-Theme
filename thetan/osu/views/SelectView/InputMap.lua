local InputMap = require("thetan.gyatt.InputMap")

---@class irizz.OsuSelectInputMap
---@operator call: irizz.OsuSelectView
local SelectInputMap = InputMap + {}

---@param sv irizz.OsuSelectView
function SelectInputMap:createBindings(sv)
	self.selectModals = {
		["showMods"] = function()
			sv:openModal("thetan.irizz.views.modals.ModifierModal")
		end,
		["showSkins"] = function()
			sv:openModal("thetan.irizz.views.modals.NoteSkinModal")
		end,
		["showInputs"] = function()
			sv:openModal("thetan.irizz.views.modals.InputModal")
		end,
		["showMultiplayer"] = function()
			sv:openModal("thetan.irizz.views.modals.MultiplayerModal")
		end,
		["showSettings"] = function()
			sv:openModal("thetan.irizz.views.modals.SettingsModal")
		end,
		["showKeybinds"] = function()
			sv:openModal("thetan.irizz.views.modals.KeybindModal")
		end,
		["showChartInfo"] = function()
			sv:openModal("thetan.irizz.views.modals.ChartInfoModal")
		end,
	}

	self.select = {
		["undoRandom"] = function()
			sv.selectModel:undoRandom()
		end,
		["random"] = function()
			sv.selectModel:scrollRandom()
		end,
		["autoPlay"] = function()
			sv.game.rhythmModel:setAutoplay(true)
			sv:play()
		end,
		["decreaseTimeRate"] = function()
			sv:changeTimeRate(-1)
		end,
		["increaseTimeRate"] = function()
			sv:changeTimeRate(1)
		end,
		["play"] = function()
			sv:play()
		end,
		["openEditor"] = function()
			sv:edit()
		end,
		["openResult"] = function()
			sv:result()
		end,
		["exportToOsu"] = function()
			sv.game.selectController:exportToOsu()
			sv.gameView.showMessage("exportToOsu", nil)
		end,
	}

	self.view = {
		["pauseMusic"] = function()
			sv.game.previewModel:stop()
		end,
		["showFilters"] = function()
			sv:openModal("thetan.irizz.views.modals.FiltersModal")
		end,
		["quit"] = function()
			sv:sendQuitSignal()
		end,
	}
end

return SelectInputMap
