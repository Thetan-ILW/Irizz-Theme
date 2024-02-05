local just = require("just")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textModifiers
local Font = Theme:getFonts("modifiersModal")

local Layout = require("thetan.iris.views.modals.ModifierModal.Layout")

return function (view)
    Layout:draw()

    local w, h = Layout:move("base")
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, w, h)

    w, h = Layout:move("modalName")
    love.graphics.setColor(Color.text)
    love.graphics.setFont(Font.title)
    just.text(Text.modifiers)
end