local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.KeybindModal.ViewConfig")
local Theme = require("thetan.irizz.views.Theme")

local KeybindModal = Modal + {}

KeybindModal.name = "KeybindModal"
KeybindModal.viewConfig = ViewConfig()
KeybindModal.keybinds = {
	view = "none",
	viewName = "",
	formattedGroups = {},
}

local function getSelectKeybinds(self)
	local groups = {
		{ "global", Theme.keybindsGlobal },
		{ "songSelect", Theme.keybindsSongSelect },
		{ "largeList", Theme.keybindsLargeList },
		{ "smallList", Theme.keybindsSmallList },
	}

	for _, keyValue in ipairs(groups) do
		local name = keyValue[1]
		local localization = keyValue[2]
		table.insert(self.keybinds.formattedGroups, { name, self.actionModel:formatGroup(name, localization) })
	end

	self.keybinds.view = "select"
end

local function getResultKeybinds(self)
	local groups = {
		{ "global", Theme.keybindsGlobal },
		{ "resultScreen", Theme.keybindsResult },
	}

	for _, keyValue in ipairs(groups) do
		local name = keyValue[1]
		local localization = keyValue[2]
		table.insert(self.keybinds.formattedGroups, { name, self.actionModel:formatGroup(name, localization) })
	end

	self.keybinds.view = "result"
end

function KeybindModal:onShow()
	local viewName = self.game.gameView:getViewName()

	self.viewConfig:reset()

	if viewName ~= self.keybinds.view then
		self.keybinds.formattedGroups = {}
		if viewName == "select" then
			return getSelectKeybinds(self)
		elseif viewName == "result" then
			return getResultKeybinds(self)
		end
	end
end

function KeybindModal:new(game)
	self.game = game
	self.actionModel = self.game.actionModel
end

return KeybindModal
