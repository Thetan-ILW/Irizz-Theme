local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.KeybindModal.ViewConfig")
local Theme = require("thetan.irizz.views.Theme")

local KeybindModal = Modal + {}

KeybindModal.name = "KeybindModal"
KeybindModal.viewConfig = ViewConfig
KeybindModal.keybinds = {
    view = "none",
    viewName = "",
    formattedGroups = {}
}

local function getSelectKeybinds(self)
    local groups = {
        global = Theme.keybindsGlobal,
        songSelect = Theme.keybindsSongSelect,
        largeList = Theme.keybindsLargeList,
        smallList = Theme.keybindsSmallList
    }

    for name, format in pairs(groups) do
        self.keybinds.formattedGroups[name] = self.actionModel:formatGroup(name, format)
    end

    self.keybinds.view = "select"
end

function KeybindModal:onShow()
    local viewName = self.game.gameView:getViewName()

    if viewName ~= self.keybinds.view then
        if viewName == "select" then
            return getSelectKeybinds(self)
        end
    end
end

function KeybindModal:new(game)
    self.game = game
    self.actionModel = self.game.actionModel
end

return KeybindModal
