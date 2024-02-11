local just = require("just")
local imgui = require("imgui")
local gfx_util = require("gfx_util")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textNoteSkins
local Font = Theme:getFonts("noteSkinModal")

local Layout = require("thetan.iris.views.modals.NoteSkinModal.Layout")

local ViewConfig = {}

function ViewConfig:noteSkins(view)
    local w, h = Layout:move("noteSkins")
    self.noteSkinListView:draw(w, h)
    love.graphics.setColor(Color.border)
    love.graphics.rectangle("line", 0, 0, w, h)
end

local scrollYconfig = 0

function ViewConfig:noteSkinSettings(view)
    local w, h = Layout:move("noteSkinSettings")

    love.graphics.setColor(Color.border)
    love.graphics.rectangle("line", 0, 0, w, h)

    local selectedNoteSkin = self.noteSkinListView.selectedNoteSkin

    local config = selectedNoteSkin.config
	if not config or not config.draw then
        love.graphics.setFont(Font.noSettings)
        love.graphics.setColor(Color.text)
        gfx_util.printFrame(Text.noSettings, 0, 0, w, h, "center", "center")
		return
	end

    love.graphics.setFont(Font.noteSkinSettings)
    just.push()
    imgui.Container("NoteSkinView", w, h, h/20, h, scrollYconfig)
    config:draw(w, h)
    scrollYconfig = imgui.Container()
	just.pop()
end

function ViewConfig:draw(view)
    Layout:draw()
    local w, h = Layout:move("base")
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, w, h)

    w, h = Layout:move("modalName")
    love.graphics.setColor(Color.text)
    love.graphics.setFont(Font.title)
    gfx_util.printFrame(Text.noteSkins, 0, 0, w, h, "center", "center")

    self:noteSkins(view)
    self:noteSkinSettings(view)
end

return ViewConfig