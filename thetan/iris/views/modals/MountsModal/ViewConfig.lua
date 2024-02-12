local gfx_util = require("gfx_util")

local Layout = require("thetan.iris.views.modals.MountsModal.Layout")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textMounts
local Font = Theme:getFonts("mountsModal")

local ViewConfig = {}

function ViewConfig:mounts(view)
    local w, h = Layout:move("window")

    Theme:panel(w, h)
    Theme:border(w, h)
end

function ViewConfig:buttons(view)
    local w, h = Layout:move("buttons")

    Theme:panel(w, h)
    Theme:border(w, h)
end

function ViewConfig:info(vies)
    local w, h = Layout:move("info")

    love.graphics.setColor(Color.text)
    love.graphics.setFont(Font.name)
    gfx_util.printFrame(Text.mounts, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
    Layout:draw()

    local w, h = Layout:move("base")
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, w, h)

    w, h = Layout:move("modalName")
    love.graphics.setColor(Color.text)
    love.graphics.setFont(Font.title)
    gfx_util.printFrame(Text.mounts, 0, 0, w, h, "center", "center")

    self:mounts(view)
    self:buttons(view)
    self:info(view)
end

return ViewConfig