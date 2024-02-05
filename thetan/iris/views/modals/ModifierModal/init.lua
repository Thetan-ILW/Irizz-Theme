local just = require("just")
local flux = require("flux")
local gfx_util = require("gfx_util")

local ViewConfig = require("thetan.iris.views.modals.ModifierModal.ViewConfig")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors

local ModifierModal = {}

ModifierModal.state = "closed"
ModifierModal.alpha = 0

local function closed()
    ModifierModal.state = "closed"
end

local function open()
    ModifierModal.state = "open"
end

function ModifierModal:show()
    self.state = "opens"

    if self.hideTween then
        self.hideTween:stop()
        self.hideTween = nil
    end

    self.showTween = flux.to(self, 0.22, {alpha = 1}):ease("quadout"):oncomplete(open)
end

function ModifierModal:hide()
    if self.showTween then
        self.showTween:stop()
        self.showTween = nil
    end

    self.hideTween = flux.to(self, 0.22, {alpha = 0}):ease("quadout"):oncomplete(closed)
end

function ModifierModal:draw(view)
    if (just.keypressed("f1") or just.keypressed("escape")) and self.state ~= "opens" then
        self:hide()
    end

    local previousCanvas = love.graphics.getCanvas()
    self.canvas = gfx_util.getCanvas("ModifierView")

    love.graphics.setCanvas(self.canvas)
        love.graphics.clear()
        ViewConfig(self)
    love.graphics.setCanvas(previousCanvas)

    love.graphics.origin()
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(self.canvas)
end

return ModifierModal
