local class = require("class")
local just = require("just")
local time_util = require("time_util")
local gfx_util = require("gfx_util")
local loop = require("loop")

local Layout = require("thetan.iris.views.SelectView.Layout")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textHeader
local font

local BackgroundView = require("sphere.views.BackgroundView")
local Logo = require("sphere.views.logo")

local ViewConfig = class()

function ViewConfig:new(game)
    font = Theme:getFonts("header")
    BackgroundView.game = game

    local path = "userdata/avatar.png"
    if love.filesystem.getInfo(path) then
        self.avatarImage = love.graphics.newImage(path)
    else
        self.avatarImage = love.graphics.newImage("iris/avatar.png")
    end
end

---@param view table
local function Background(view)
	local w, h = Layout:move("background")

	local dim = view.game.configModel.configs.settings.graphics.dim.select
	
	BackgroundView:draw(w, h, dim, 0.01)
end

function ViewConfig:Header(view)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("smooth")
    love.graphics.setFont(font.anyText)

    local w, h = Layout:move("buttons")
    local r = h / 1.4
    love.graphics.setColor({0.08, 0.35, 0.79, 1})
    love.graphics.circle("fill", r, r, r)
    love.graphics.setColor({1, 1, 1, 1})
    love.graphics.circle("line", r, r, r)
    Logo.draw("fill", 0, 0, r*2)

    local settingsText = font.anyText:getWidth(Text.settings)
    local songsText = font.anyText:getWidth(Text.songs)
    local collectionsText = font.anyText:getWidth(Text.collections)

    just.indent(30)
    local x = r*2
    local y = h - 8

    love.graphics.setColor(view.screenXTarget > 0 and Color.headerSelect or Color.text)
    gfx_util.printBaseline(Text.settings, x, y, w, 1, "left")
    love.graphics.rectangle("fill", x, y + 10, settingsText, 4)

    if just.is_over(settingsText, h + 10, x) then
        if just.mousepressed(1) then
            view:moveScreen(-1, true)
        end
    end

    just.indent(30)
    x = x + settingsText

    love.graphics.setColor(view.screenXTarget == 0 and Color.headerSelect or Color.text)
    gfx_util.printBaseline(Text.songs, x, y, w, 1, "left")
    love.graphics.rectangle("fill", x, y + 10, songsText, 4)

    if just.is_over(songsText, h + 10, x) then
        if just.mousepressed(1) then
            view:switchToSongSelect() ---------------------------------------------
            view:moveScreen(0, true) -----------------------------------------
        end
    end

    just.indent(30)
    x = x + songsText

    love.graphics.setColor(view.screenXTarget < 0 and Color.headerSelect or Color.text)
    gfx_util.printBaseline(Text.collections, x, y, w, 1, "left")
    love.graphics.rectangle("fill", x, y + 10, collectionsText, 4)

    if just.is_over(collectionsText, h + 10, x) then
        if just.mousepressed(1) then
            view:moveScreen(1, true)
        end
    end

    w, h = Layout:move("user")
    
    if just.is_over(w, h) then
        if just.mousepressed(1) then
            view:openModal("sphere.views.OnlineView")
        end
    end
    
    love.graphics.setColor(Color.text)
    local username = view.game.configModel.configs.online.user.name or "Not logged in"
    local time = time_util.format(loop.time - loop.startTime)

    r = h / 1.4
    local imageW = (r*2) / self.avatarImage:getPixelWidth()
    local imageH = (r*2) / self.avatarImage:getPixelHeight()

    local function avatarStencil()
        love.graphics.circle("fill", w - r, r, r)
    end

    love.graphics.stencil(avatarStencil)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.draw(self.avatarImage,
        w - (r * 2), 0, 0,
        imageW,
        imageH
    )
    love.graphics.setStencilTest()
    love.graphics.circle("line", w - r, r, r)

    just.indent(-30)
    gfx_util.printBaseline(username, -r*2, h - 8, w, 1, "right")
    local userTextWidth = font.anyText:getWidth(username)
    love.graphics.rectangle("fill", w + (-r*2) - userTextWidth, h + 2, userTextWidth, 4)
    local timeTextWidth = font.anyText:getWidth(time)
    just.indent(-30)
    gfx_util.printBaseline(time, -r*2 - userTextWidth, h - 8, w, 1, "right")
    love.graphics.rectangle("fill", w + (-r*2) - userTextWidth - timeTextWidth, h + 2, timeTextWidth, 4)
end


function ViewConfig:draw(view)
    Background(view)
    self:Header(view)
end

return ViewConfig