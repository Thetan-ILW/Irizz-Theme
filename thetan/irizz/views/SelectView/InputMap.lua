local InputMap = require("thetan.gyatt.InputMap")

local SelectInputMap = InputMap + {}

function SelectInputMap:createBindings(sv, a)
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
			if not sv.game.selectModel:notechartExists() then
				return
			end

			sv:changeScreen("editorView")
		end,
		["openResult"] = function()
			sv:result()
		end,
	}

	self.view = {
		["moveScreenLeft"] = function()
			sv:moveScreen(-1)
		end,
		["moveScreenRight"] = function()
			sv:moveScreen(1)
		end,
		["pauseMusic"] = function()
			sv.game.previewModel:stop()
		end,
		["showFilters"] = function()
			sv:openModal("thetan.irizz.views.modals.FiltersModal")
		end,
	}
end

return SelectInputMap
