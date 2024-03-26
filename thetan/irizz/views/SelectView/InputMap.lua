local InputMap = require("thetan.gyatt.InputMap")
local gyatt = require("thetan.gyatt")

local SelectInputMap = InputMap + {}

function InputMap:createBindings(sv, a)
	self.selectModals = {
		[a.showMods] = function()
			sv:openModal("thetan.irizz.views.modals.ModifierModal")
		end,
		[a.showSkins] = function()
			sv:openModal("thetan.irizz.views.modals.NoteSkinModal")
		end,
		[a.showInputs] = function()
			sv:openModal("thetan.irizz.views.modals.InputModal")
		end,
		[a.showFilters] = function()
			sv:openModal("thetan.irizz.views.modals.FiltersModal")
		end,
		[a.showMultiplayer] = function()
			sv:openModal("thetan.irizz.views.modals.MultiplayerModal")
		end
	}

	self.select = {
		[a.undoRandom] = function()
			sv.selectModel:undoRandom()
		end,
		[a.random] = function()
			sv.selectModel:scrollRandom()
		end,
		[a.autoPlay] = function()
			sv.game.rhythmModel:setAutoplay(true)
			sv:play()
		end,
		[a.decreaseTimeRate] = function()
			sv:changeTimeRate(-1)
		end,
		[a.increaseTimeRate] = function()
			sv:changeTimeRate(1)
		end,
		[a.play] = function()
			sv:play()
		end,
		[a.openEditor] = function()
			if not sv.game.selectModel:notechartExists() then
				return
			end

			sv:changeScreen("editorView")
		end
	}

	self.screen = {
		[a.insertMode] = function()
			gyatt.vimMode = "Insert"
		end,
		[a.normalMode] = function()
			gyatt.vimMode = "Normal"
			local selectModel = sv.game.selectModel
			selectModel:debouncePullNoteChartSet()
		end,
		[a.moveScreenLeft] = function()
			sv:moveScreen(-1)
		end,
		[a.moveScreenRight] = function()
			sv:moveScreen(1)
		end,
		[a.pauseMusic] = function()
			sv.game.previewModel:stop()
		end
	}
end

return SelectInputMap
