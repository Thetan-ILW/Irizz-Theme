local class = require("class")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textKeybinds
local Font = Theme:getFonts("keybindsModal")
local Layout = require("thetan.irizz.views.modals.KeybindModal.Layout")

local ViewConfig = class()

function ViewConfig:keybinds(view)
    local w, h = Layout:move("keybinds")

    local groups = view.keybinds.formattedGroups

    local groupCount = 0
    for _, _ in pairs(groups) do
        groupCount = groupCount + 1
    end

    local groupW = w / groupCount
    love.graphics.setFont(Font.keybinds)
    love.graphics.setColor(Color.text)
    local i = 0

    for _, group in pairs(groups) do
        local x = groupW * i
        i = i + 1

        for description, bind in pairs(group) do
            gyatt.frame(bind, x + 15, 0, groupW, h, "left", "top")
            gyatt.frame(description, x - 15, 0, groupW, h, "right", "top")
            love.graphics.translate(0, 40)
        end

        w, h = Layout:move("keybinds")
        love.graphics.rectangle("fill", x, 0, 4, h)
    end
end

function ViewConfig:draw(view)
    Layout:draw()

    local w, h = Layout:move("base")
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, w, h)

    w, h = Layout:move("modalName")
    love.graphics.setColor(Color.text)
    love.graphics.setFont(Font.title)
    local text = Text.keybindsFor:format(Text[view.keybinds.view])
    gyatt.frame(text, 0, 0, w, h, "center", "center")

    self:keybinds(view)
end

return ViewConfig
