local InputMap = require("thetan.gyatt.InputMap")

local math_util = require("math_util")

---@class osu.SelectInputMap
---@operator call: osu.SelectInputMap
local SelectInputMap = InputMap + {}

---@param sv osu.SelectView
---@param delta number
local function increaseVolume(sv, direction)
	local configs = sv.game.configModel.configs
	local settings = configs.settings
	local a = settings.audio
	local v = a.volume

	v.master = math_util.clamp(v.master + (direction * 0.05), 0, 1)

	sv.assetModel:updateVolume()
	sv.notificationView:show("volumeChanged", v.master * 100)
end

---@param sv osu.SelectView
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
			sv:select()
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
		["moveScreenLeft"] = function()
			sv:changeGroup("charts")
		end,
		["moveScreenRight"] = function()
			sv:changeGroup("last_visited_locations")
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

	self.music = {
		["pauseMusic"] = function()
			sv.game.previewModel:stop()
		end,
		["increaseVolume"] = function()
			increaseVolume(sv, 1)
		end,
		["decreaseVolume"] = function()
			increaseVolume(sv, -1)
		end,
	}
end

return SelectInputMap
