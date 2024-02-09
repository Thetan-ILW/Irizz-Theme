local class = require("class")
local flux = require("flux")

local just = require("just")
local gfx_util = require("gfx_util")

local Modal = class()

Modal.alpha = 0

function Modal:show()
    if self.hideTween then
        self.hideTween:stop()
        self.hideTween = nil
    end

    self.showTween = flux.to(self, 0.22, {alpha = 1}):ease("quadout")
end

function Modal:hide()
    if self.showTween then
        self.showTween:stop()
        self.showTween = nil
    end

    self.hideTween = flux.to(self, 0.44, {alpha = -1}):ease("quadout")
end

function Modal:draw(view)
    if (just.keypressed("f1") or just.keypressed("escape")) and self.alpha > 0.1 then
        self:hide()
    end

    local previousCanvas = love.graphics.getCanvas()
    self.canvas = gfx_util.getCanvas("ModifierView")

    love.graphics.setCanvas({self.canvas, stencil=true})
        love.graphics.clear()
        self.viewConfig:draw(self)
    love.graphics.setCanvas(previousCanvas)

    love.graphics.origin()
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(self.canvas)
end

return Modal