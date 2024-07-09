local class = require("class")
local flux = require("flux")
local gyatt = require("thetan.gyatt")

local Layout = require("thetan.irizz.views.MainMenuView.Layout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textMainMenu
local font

local MainMenu = class()

MainMenu.active = false
MainMenu.alpha = 0
MainMenu.tween = nil

local gameView
local icons

---@param game_view sphere.GameView
function MainMenu:new(game_view)
	gameView = game_view
	font = Theme:getFonts("mainMenuView")
	icons = Theme.icons
end

---@return boolean
function MainMenu:isActive()
	return self.active
end

---@return number
function MainMenu:getAlpha()
	return self.alpha
end

function MainMenu:toggle()
	self.active = not self.active

	if self.tween then
		self.tween:stop()
	end

	if self.active then
		self.tween = flux.to(self, 0.22, { alpha = 1 }):ease("quadout")
	else
		self.tween = flux.to(self, 0.22, { alpha = 0 }):ease("quadout")
	end
end

local gfx = love.graphics

local function getTimeOfDay()
	local time = os.date("*t")
	if time.hour < 12 then
		return Text.morning
	elseif time.hour < 17 then
		return Text.day
	elseif time.hour < 20 then
		return Text.evening
	else
		return Text.night
	end
end

local function title()
	local w, h = Layout:move("screen")
	gfx.setColor(Color.text)
	gfx.setFont(font.title)
	if NOESIS_INSTALLED then
		gyatt.frame(Text.welcomeToNoesis, 0, -20, w, h, "center", "top")
	else
		gyatt.frame(Text.welcomeToSoundsphere, 0, -20, w, h, "center", "top")
	end
	gfx.setFont(font.timeOfDay)
	gyatt.frame(getTimeOfDay(), 0, font.title:getHeight() - 20, w, h, "center", "top")
end

local function button(text, icon, spacing, size)
	local w, _ = icon:getDimensions()

	local icon_scale = (size / w) * 0.65
	local icon_pos = (size / 2) - ((w * icon_scale) / 2)

	local changed, active, hovered
	if not gameView.modal then
		changed, active, hovered = gyatt.button(text .. "mainMenu", gyatt.isOver(size, size))
	end

	gfx.setColor(Color.panel)
	gfx.rectangle("fill", 0, 0, size, size, 12, 12)

	gfx.setColor(hovered and Color.accent or { 1, 1, 1, 1 })
	gfx.draw(icon, icon_pos, icon_pos - 10, 0, icon_scale, icon_scale)

	gfx.setColor(Color.text)
	gyatt.frame(text, 0, -5, size, size, "center", "bottom")

	gfx.rectangle("line", 0, 0, size, size, 12, 12)
	gfx.translate(spacing + size, 0)

	return changed
end

function MainMenu:songSelectButtons()
	local w, h = Layout:move("screen")

	local button_count = 7

	local button_size = w / 10
	local spacing = 30

	local position = (w / 2) - (((button_size * button_count) + (spacing * (button_count - 1))) / 2)

	gfx.setLineWidth(8)
	gfx.setFont(font.buttons)

	gfx.translate(position, (h / 2) - (button_size / 2))

	if button(Text.modifiers, icons.modifiers, spacing, button_size) then
		gameView:openModal("thetan.irizz.views.modals.ModifierModal")
	end

	if button(Text.filters, icons.filters, spacing, button_size) then
		gameView:openModal("thetan.irizz.views.modals.FiltersModal")
	end

	if button(Text.noteSkins, icons.noteSkins, spacing, button_size) then
		gameView:openModal("thetan.irizz.views.modals.NoteSkinModal")
	end

	if button(Text.inputs, icons.inputs, spacing, button_size) then
		gameView:openModal("thetan.irizz.views.modals.InputModal")
	end

	if button(Text.keyBinds, icons.keyBinds, spacing, button_size) then
		gameView:openModal("thetan.irizz.views.modals.KeybindModal")
	end

	if button(Text.multiplayer, icons.multiplayer, spacing, button_size) then
		gameView:openModal("thetan.irizz.views.modals.MultiplayerModal")
	end

	if button(Text.chartEditor, icons.chartEditor, spacing, button_size) then
		if not gameView.game.selectModel:notechartExists() then
			return
		end

		self:toggle()
		gameView.view:changeScreen("editorView")
	end
end

function MainMenu:resultButtons(view)
	local w, h = Layout:move("screen")

	local button_count = 3

	local button_size = w / 10
	local spacing = 30

	local position = (w / 2) - (((button_size * button_count) + (spacing * (button_count - 1))) / 2)

	gfx.setLineWidth(8)
	gfx.setFont(font.buttons)

	gfx.translate(position, (h / 2) - (button_size / 2))

	if button(Text.retry, icons.retry, spacing, button_size) then
		view:play("retry")
		self:toggle()
	end

	if button(Text.watch, icons.watch, spacing, button_size) then
		view:play("replay")
		self:toggle()
	end

	if button(Text.submit, icons.submit, spacing, button_size) then
		view:submitScore()
	end
end

---@param screen_name string
---@param view sphere.ScreenView
function MainMenu:draw(screen_name, view)
	if self.alpha == 0 then
		return
	end

	Layout:draw()

	local previousCanvas = gfx.getCanvas()
	local layer = gyatt.getCanvas("mainMenuView")

	gfx.setCanvas({ layer, stencil = true })
	gfx.clear()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.33)
	love.graphics.rectangle("fill", 0, 0, w, h)

	title()

	if screen_name == "select" then
		self:songSelectButtons()
	elseif screen_name == "result" then
		self:resultButtons(view)
	end

	gfx.setCanvas({ previousCanvas, stencil = true })

	gfx.origin()

	local alpha = self.alpha

	if gameView.modal then
		alpha = alpha - gameView.modal.alpha
	end

	gfx.setColor(1, 1, 1, alpha)
	gfx.draw(layer)
end

return MainMenu
