local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")

local Layout = require("thetan.irizz.views.modals.OnlineModal.Layout")

local TextBox = require("thetan.irizz.imgui.TextBox")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textOnline
local Font = Theme:getFonts("onlineModal")
local cfg = Theme.imgui

local ViewConfig = {}

local active
ViewConfig.email = ""
ViewConfig.password = ""

function ViewConfig:status(view)
	local w, h = 0, 0

	if active then
		w, h = Layout:move("statusOnline")
	else
		w, h = Layout:move("status")
	end

	local text = active and Text.loggedIn or Text.notLoggedIn

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.status)
	gfx_util.printFrame(text, 0, 0, w, h, "center", "center")
end

function ViewConfig:fields(view)
	if active then
		return
	end

	local w, h = Layout:move("fields")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.fields)
	local changed, text = TextBox("email", { self.email, Text.emailPlaceholder }, nil, w, h, false)

	if changed == "text" then
		self.email = text
	end

	changed, text = TextBox("password", { self.password, Text.passwordPlaceholder }, nil, w, h, true)

	if changed == "text" then
		self.password = text
	end
end

function ViewConfig:logout(view)
	local w, h = Layout:move("buttonsOnline")
	imgui.setSize(w, h, w / 2.5, cfg.size)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.buttons)
	local width = love.graphics.getFont():getWidth(Text.logout)
	love.graphics.translate(w / 2 - width, 0)

	if imgui.button("logout", Text.logout) then
		view.game.onlineModel.authManager:logout()
	end
end

function ViewConfig:login(view)
	local w, h = Layout:move("buttons")
	imgui.setSize(w, h, w / 2.5, cfg.size)

	local imguiSize = Theme.imgui.size
	local nextItemOffset = Theme.imgui.nextItemOffset

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.buttons)
	local width1 = love.graphics.getFont():getWidth(Text.connect)
	local width2 = love.graphics.getFont():getWidth(Text.quickConnect)

	love.graphics.translate(w / 2 - (width1 + imguiSize) / 2, 0)

	if imgui.button("login", Text.connect) then
		view.game.onlineModel.authManager:login(self.email, self.password)
	end

	w, h = Layout:move("buttons")
	love.graphics.translate(w / 2 - (width2 + imguiSize) / 2, imguiSize + nextItemOffset)

	if imgui.button("loginBrowser", Text.quickConnect) then
		view.game.onlineModel.authManager:quickLogin()
	end
end

function ViewConfig:draw(view)
	Layout:draw()

	active = next(view.game.configModel.configs.online.session)
	self:status(view)

	self:fields(view)

	if active then
		self:logout(view)
		return
	end

	self:login(view)
end

return ViewConfig
