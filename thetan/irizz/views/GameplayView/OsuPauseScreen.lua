local class = require("class")

local flux = require("flux")
local just = require("just")
local gyatt = require("thetan.gyatt")
local table_util = require("table_util")

local Layout = require("thetan.irizz.views.GameplayView.OsuLayout")

local OsuPauseScreen = class()

OsuPauseScreen.tween = nil
OsuPauseScreen.alpha = 0

local failed = false

local function play(source)
    if source then
        source:stop()
        source:play()
    end
end

local function stop(source)
    if source then
        source:stop()
    end
end

local function setVolume(source, volume)
    if source then
        source:setVolume(volume)
    end
end

function OsuPauseScreen:new(assets)
    table_util.copy(assets, self)
end

function OsuPauseScreen:show()
    if self.tween then
        self.tween:stop()
    end
    self.tween = flux.to(self, 0.22, { alpha = 1 }):ease("quadout")

    play(self.loopAudio)
end

function OsuPauseScreen:hide()
    if self.tween then
        self.tween:stop()
    end

    self.tween = flux.to(self, 0.22, { alpha = 0 }):ease("quadout")

    stop(self.loopAudio)
end

function OsuPauseScreen:unload()
    stop(self.loopAudio)
end

function OsuPauseScreen:overlay(view)
    local image = self.overlayImage

    if failed then
        image = self.overlayFailImage
    end

    if not image then
        return
    end

    Layout:move("overlay")

    local iw, ih = image:getDimensions()
    love.graphics.translate(-iw / 2, -ih / 2)
    love.graphics.draw(image)
end

local function button(image, position_name)
    if not image then
        return
    end

    local iw, ih = image:getDimensions()
    local w, h = Layout:move(position_name)

    local x = -(iw / 2)
    local y = -(ih / 2)

    love.graphics.translate(x, y)
    local changed, active, hovered = just.button("button" .. position_name, just.is_over(iw, ih))

    love.graphics.setColor({ 1, 1, 1, 1 })

    if hovered then
        love.graphics.setColor({ 0.7, 0.7, 1, 1 })
    end

    love.graphics.draw(image)

    return changed
end

function OsuPauseScreen:buttons(view)
    local gameplayController = view.game.gameplayController

    if not failed then
        if button(self.continueImage, "continue") then
            play(self.continueClick)
            gameplayController:changePlayState("play")
            self:hide()
        end
    end

    if button(self.retryImage, "retry") then
        play(self.retryClick)
        gameplayController:changePlayState("retry")
        self:hide()
    end

    if button(self.backImage, "back") then
        play(self.backClick)
        view:quit()
    end
end

function OsuPauseScreen:updateAudio(view)
    local configs = view.game.configModel.configs
    local settings = configs.settings
    local a = settings.audio
    local volume = a.volume.master * a.volume.music

    setVolume(self.loopAudio, volume * self.alpha)
    setVolume(self.continueClick, volume)
    setVolume(self.retryClick, volume)
    setVolume(self.backClick, volume)
end

function OsuPauseScreen:draw(view, game_canvas)
    failed = view.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed()

    self:updateAudio(view)

    love.graphics.setColor({ 1, 1, 1, 1 })
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.origin()
    love.graphics.draw(game_canvas)
    love.graphics.setBlendMode("alpha")

    Layout:draw()

    local prev_canvas = love.graphics.getCanvas()
    local layer = gyatt.getCanvas("pauseOverlay")
    love.graphics.setCanvas({ layer, stencil = true })
    love.graphics.clear()
    self:overlay(view)
    self:buttons(view)
    love.graphics.setCanvas({ prev_canvas, stencil = true })

    love.graphics.origin()
    local a = self.alpha
    love.graphics.setColor(a, a, a, a)
    love.graphics.draw(layer)
end

return OsuPauseScreen
