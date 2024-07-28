local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")

local Layout = require("thetan.irizz.views.modals.OnlineModal.Layout")

local TextBox = require("thetan.irizz.imgui.TextBox")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local cfg = Theme.imgui

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ViewConfig = IViewConfig + {}

local active
ViewConfig.email = ""
ViewConfig.password = ""

---@param assets irizz.IrizzAssets
function ViewConfig:new(assets)
	text, font = assets.localization:get("onlineModal")
	assert(text and font)
end

function ViewConfig:status(view)
	local w, h = 0, 0

	if active then
		w, h = Layout:move("statusOnline")
	else
		w, h = Layout:move("status")
	end

	local label = active and text.loggedIn or text.notLoggedIn

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.status)
	gyatt.frame(label, 0, 0, w, h, "center", "center")
end

function ViewConfig:fields(view)
	if active then
		return
	end

	local w, h = Layout:move("fields")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.fields)
	local changed, input = TextBox("email", { self.email, text.emailPlaceholder }, nil, w, h, false)

	if changed == "text" then
		self.email = input
	end

	changed, input = TextBox("password", { self.password, text.passwordPlaceholder }, nil, w, h, true)

	if changed == "text" then
		self.password = input
	end
end

function ViewConfig:logout(view)
	local w, h = Layout:move("buttonsOnline")
	imgui.setSize(w, h, w / 2.5, cfg.size)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.buttons)
	local width = love.graphics.getFont():getWidth(text.logout)
	love.graphics.translate(w / 2 - width, 0)

	if imgui.button("logout", text.logout) then
		view.game.onlineModel.authManager:logout()
	end
end

function ViewConfig:login(view)
	local w, h = Layout:move("buttons")
	imgui.setSize(w, h, w / 2.5, cfg.size)

	local imguiSize = Theme.imgui.size
	local nextItemOffset = Theme.imgui.nextItemOffset

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.buttons)
	local width1 = love.graphics.getFont():getWidth(text.connect) * gyatt.getTextScale()
	local width2 = love.graphics.getFont():getWidth(text.quickConnect) * gyatt.getTextScale()

	love.graphics.translate(w / 2 - (width1 + imguiSize) / 2, 0)

	if imgui.button("login", text.connect) then
		view.game.onlineModel.authManager:login(self.email, self.password)
	end

	w, h = Layout:move("buttons")
	love.graphics.translate(w / 2 - (width2 + imguiSize) / 2, imguiSize + nextItemOffset)

	if imgui.button("loginBrowser", text.quickConnect) then
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
