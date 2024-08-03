local class = require("class")
local just = require("just")
local time_util = require("time_util")
local gyatt = require("thetan.gyatt")
local loop = require("loop")

local Layout = require("thetan.irizz.views.HeaderLayout")

local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

---@class irizz.HeaderView
---@operator call: irizz.HeaderView
---@field gameIcon love.Image
---@field avatar love.Image
local ViewConfig = class()

---@type skibidi.ActionModel
local actionModel

local gfx = love.graphics

local profile_label = ""

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
---@param screen "select" | "result" | "multiplayer"
function ViewConfig:new(game, assets, screen)
	self.gameIcon = assets.images.gameIcon
	self.avatar = assets.images.avatar
	font = assets.localization.fontGroups.header
	text = assets.localization.textGroups.header

	self.screen = screen
	actionModel = game.actionModel

	if screen == "select" then
		self.buttons = self.songSelectButtons
	elseif screen == "result" then
		self.buttons = self.resultButtons
	else
		self.buttons = self.multiplayerButtons
	end

	self:updateInfo(game)
end

---@param game sphere.GameController
function ViewConfig:updateInfo(game)
	---@type skibidi.PlayerProfileModel
	local profile = game.playerProfileModel

	local chartview = game.selectModel.chartview
	local regular, ln = profile:getDanClears(chartview.chartdiff_inputmode)
	profile_label = ("%ipp [%s/%s]"):format(profile.pp, regular, ln)
end

---@param id string
---@param image love.Image
---@param r number
local function circleImage(id, image, r)
	local imageW = (r * 2) / image:getPixelWidth()
	local imageH = (r * 2) / image:getPixelHeight()

	local function avatarStencil()
		gfx.circle("fill", r, r, r)
	end

	gfx.stencil(avatarStencil)
	gfx.setStencilTest("greater", 0)
	gfx.draw(image, 0, 0, 0, imageW, imageH)
	gfx.setStencilTest()
	gfx.circle("line", r, r, r)

	local clicked = just.button("circleImage" .. id, just.is_over(r * 2, r * 2))
	return clicked
end

local function button(label, right_side, active)
	local label_w = font.anyText:getWidth(label) * gyatt.getTextScale()

	if right_side then
		gfx.translate(-label_w, 0)
	end

	gfx.setColor(colors.ui.panel)
	gfx.rectangle("fill", -8, 10, label_w + 16, 43, 8, 8)

	gfx.setColor(active and colors.ui.headerSelect or colors.ui.text)
	gyatt.frame(label, 0, 3, label_w, 43, "center", "center")
	gfx.rectangle("fill", 0, 43, label_w, 4)

	if just.is_over(label_w, 43) then
		if just.mousepressed(1) then
			gfx.translate(right_side and -(30 + label_w) or (30 + label_w), 0)
			return true
		end
	end

	gfx.translate(right_side and -30 or (30 + label_w), 0)

	return false
end

function ViewConfig:songSelectButtons(view)
	gfx.setLineWidth(2)
	gfx.setLineStyle("smooth")
	gfx.setFont(font.anyText)

	local w, h = Layout:move("buttons")
	local r = h / 1.4

	if circleImage("gameIcon", self.gameIcon, r) then
		--view.mainMenuView:toggle()
	end

	gfx.translate(r * 2 + 30, 0)

	local active = view.screenXTarget > 0
	if button(text.settings, false, active) then
		view:moveScreen(-1, true)
	end

	active = view.screenXTarget == 0
	if button(text.songs, false, active) then
		view:moveScreen(0, true)
	end

	active = view.screenXTarget < 0
	if button(text.collections, false, active) then
		view:moveScreen(1, true)
	end
end

function ViewConfig:resultButtons(view)
	gfx.setLineWidth(2)
	gfx.setLineStyle("smooth")
	gfx.setFont(font.anyText)

	local w, h = Layout:move("buttons")
	local r = h / 1.4

	if circleImage("gameIcon", self.gameIcon, r) then
	end

	gfx.translate(r * 2 + 30, 0)

	if button(text.songs, false, false) then
		view:sendQuitSignal()
	end
end

function ViewConfig:multiplayerButtons(view)
	gfx.setLineWidth(2)
	gfx.setLineStyle("smooth")
	gfx.setFont(font.anyText)

	local w, h = Layout:move("buttons")
	local r = h / 1.4

	if circleImage("gameIcon", self.gameIcon, r) then
	end

	local panelHeight = font.anyText:getHeight() + 8

	if button(text.songs, w, h, panelHeight, false, false) then
		view.game.gameView:sendQuitSignal()
	end

	if button(text.leaveRoom, w, h, panelHeight, false, false) then
		view:leaveRoom()
	end
end

function ViewConfig:vimMode(view)
	if not actionModel.isVimMode() then
		return
	end

	local w, h = Layout:move("vimMode")

	local vim_mode = actionModel.getVimMode()
	local count = actionModel.getCount()

	vim_mode = ("%s [%i]"):format(vim_mode, count)

	gfx.setColor(colors.ui.panel)
	local textW = font.anyText:getWidth(vim_mode) * gyatt.getTextScale()
	gfx.rectangle("fill", w / 2 - textW / 2 - 8, 10, textW + 16, 43, 8, 8)

	gfx.setColor(colors.ui.text)
	gfx.setFont(font.anyText)
	gyatt.frame(vim_mode, 0, 3, w, h, "center", "center")
	gfx.rectangle("fill", w / 2 - textW / 2, h + 2, textW, 4)
end

function ViewConfig:rightSide(view)
	local w, h = Layout:move("user")

	if just.is_over(w, h) then
		if just.mousepressed(1) then
			view:openModal("thetan.irizz.views.modals.OnlineModal")
		end
	end

	local configs = view.game.configModel.configs
	local drawOnlineCount = configs.irizz.showOnlineCount

	gfx.setColor(colors.ui.text)
	local username = view.game.configModel.configs.online.user.name or text.notLoggedIn
	local time = time_util.format(loop.time - loop.startTime)
	local onlineCount = #view.game.multiplayerModel.users
	onlineCount = text.online:format(onlineCount)

	local profile = self.playerProfileModel

	local r = h / 1.4

	gfx.translate(w - r * 2, 0)

	circleImage("avatar", self.avatar, r)

	gfx.translate(-r, 0)

	button(username, true, false)

	if drawOnlineCount then
		button(onlineCount, true, false)
	end

	button(profile_label, true, false)

	button(time, true, false)
end

function ViewConfig:draw(view)
	Layout:draw()
	gfx.setColor({ 1, 1, 1, 1 })
	self:buttons(view)
	self:vimMode(view)
	self:rightSide(view)
end

return ViewConfig
