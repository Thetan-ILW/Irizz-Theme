local class = require("class")
local just = require("just")
local time_util = require("time_util")
local gyatt = require("thetan.gyatt")
local loop = require("loop")

local Layout = require("thetan.irizz.views.HeaderLayout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textHeader
local font

local ViewConfig = class()

---@type irizz.ActionModel
local actionModel

local gfx = love.graphics

---@param game sphere.GameController
---@param screen "select" | "result" | "multiplayer"
function ViewConfig:new(game, screen)
	font = Theme:getFonts("header")

	self.gameIcon = Theme.gameIcon
	self.avatarImage = Theme.avatarImage
	self.screen = screen
	actionModel = game.actionModel

	if screen == "select" then
		self.buttons = self.songSelectButtons
	else
		self.buttons = self.resultButtons
	end
end

local function circleImage(image, r, x)
	local imageW = (r * 2) / image:getPixelWidth()
	local imageH = (r * 2) / image:getPixelHeight()

	local function avatarStencil()
		gfx.circle("fill", x - r, r, r)
	end

	gfx.stencil(avatarStencil)
	gfx.setStencilTest("greater", 0)
	gfx.draw(image, x - (r * 2), 0, 0, imageW, imageH)
	gfx.setStencilTest()
	gfx.circle("line", x - r, r, r)

	local clicked = just.button("circleImage" .. x, just.is_over(r * 2, r * 2))
	return clicked
end

local buttonOffset = 0
local function button(text, w, h, panelHeight, rightSide, active)
	local textW = font.anyText:getWidth(text)
	local ax = "left"
	local w2 = buttonOffset
	local x = w2
	local indent = 30

	if rightSide then
		ax = "right"
		w2 = textW - buttonOffset
		x = w - w2
		indent = -30
	end

	just.indent(indent)
	gfx.setColor(Color.panel)
	gfx.rectangle("fill", x - 8, 10, textW + 16, panelHeight, 8, 8)

	gfx.setColor(active and Color.headerSelect or Color.text)
	gyatt.baseline(text, buttonOffset, h - 8, w, 1, ax)
	gfx.rectangle("fill", x, h + 2, textW, 4)

	textW = rightSide and -textW or textW
	buttonOffset = buttonOffset + textW

	if just.is_over(textW, h + 10, x) then
		if just.mousepressed(1) then
			return true
		end
	end

	return false
end

function ViewConfig:songSelectButtons(view)
	gfx.setLineWidth(2)
	gfx.setLineStyle("smooth")
	gfx.setFont(font.anyText)

	local w, h = Layout:move("buttons")
	local r = h / 1.4

	if circleImage(self.gameIcon, r, r * 2) then
		view.gameView.mainMenuView:toggle()
	end

	buttonOffset = r * 2
	local panelHeight = font.anyText:getHeight() + 8

	local active = view.screenXTarget > 0
	if button(Text.settings, w, h, panelHeight, false, active) then
		view:moveScreen(-1, true)
	end

	active = view.screenXTarget == 0
	if button(Text.songs, w, h, panelHeight, false, active) then
		view:moveScreen(0, true)
	end

	active = view.screenXTarget < 0
	if button(Text.collections, w, h, panelHeight, false, active) then
		view:moveScreen(1, true)
	end
end

function ViewConfig:resultButtons(view)
	gfx.setLineWidth(2)
	gfx.setLineStyle("smooth")
	gfx.setFont(font.anyText)

	local w, h = Layout:move("buttons")
	local r = h / 1.4

	if circleImage(self.gameIcon, r, r * 2) then
		view.gameView.mainMenuView:toggle()
	end

	local songsText = font.anyText:getWidth(Text.songs)

	just.indent(30)
	local x = r * 2
	local y = h - 8
	local panelHeight = font.anyText:getHeight() + 8

	gfx.setColor(Color.panel)
	gfx.rectangle("fill", x - 8, 10, songsText + 16, panelHeight, 8, 8)

	gfx.setColor(Color.text)
	gyatt.baseline(Text.songs, x, y, w, 1, "left")
	gfx.rectangle("fill", x, y + 10, songsText, 4)

	if just.is_over(songsText, h + 10, x) then
		if just.mousepressed(1) then
			view.game.gameView:sendQuitSignal()
		end
	end
end

function ViewConfig:vimMode(view)
	if not actionModel.isVimMode() then
		return
	end

	local w, h = Layout:move("vimMode")

	local text = actionModel.getVimMode()
	local count = actionModel.getCount()

	text = ("%s [%i]"):format(text, count)

	gfx.setColor(Color.panel)
	local textW = font.anyText:getWidth(text)
	local panelHeight = font.anyText:getHeight() + 8
	gfx.rectangle("fill", w / 2 - textW / 2 - 8, 10, textW + 16, panelHeight, 8, 8)

	gfx.setColor(Color.text)
	gfx.setFont(font.anyText)
	gyatt.frame(text, 0, 0, w, h, "center", "center")
	gfx.rectangle("fill", w / 2 - textW / 2, h + 2, textW, 4)
end

function ViewConfig:rightSide(view)
	local w, h = Layout:move("user")

	if just.is_over(w, h) then
		if just.mousepressed(1) then
			view.game.gameView:openModal("thetan.irizz.views.modals.OnlineModal")
		end
	end

	local configs = view.game.configModel.configs
	local drawOnlineCount = configs.irizz.showOnlineCount

	gfx.setColor(Color.text)
	local username = view.game.configModel.configs.online.user.name or Text.notLoggedIn
	local time = time_util.format(loop.time - loop.startTime)
	local onlineCount = #view.game.multiplayerModel.users
	onlineCount = Text.online:format(onlineCount)

	local r = h / 1.4
	local panelHeight = font.anyText:getHeight() + 8

	circleImage(self.avatarImage, r, w)

	buttonOffset = -r * 2
	button(username, w, h, panelHeight, true)

	if drawOnlineCount then
		button(onlineCount, w, h, panelHeight, true)
	end

	button(time, w, h, panelHeight, true)
end

function ViewConfig:draw(view)
	Layout:draw()
	gfx.setColor({ 1, 1, 1, 1 })
	self:buttons(view)
	self:vimMode(view)
	self:rightSide(view)
end

return ViewConfig
