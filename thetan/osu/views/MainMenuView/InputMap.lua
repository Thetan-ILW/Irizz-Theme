local InputMap = require("thetan.gyatt.InputMap")

local math_util = require("math_util")

---@class osu.MainMenuInputMap
---@operator call: osu.MainMenuInputMap
local MainMenuInputMap = InputMap + {}

---@param sv osu.MainMenuView
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

---@param mv osu.MainMenuView
function MainMenuInputMap:createBindings(mv)
	self.view = {
		["pauseMusic"] = function()
			mv.game.previewModel:stop()
		end,
		["showFilters"] = function()
			mv:openModal("thetan.irizz.views.modals.FiltersModal")
		end,
		["quit"] = function()
			mv:sendQuitSignal()
		end,
		["increaseVolume"] = function()
			increaseVolume(mv, 1)
		end,
		["decreaseVolume"] = function()
			increaseVolume(mv, -1)
		end,
	}
end

return MainMenuInputMap
