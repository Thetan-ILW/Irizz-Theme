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

---@param game_view sphere.GameView
function MainMenu:new(game_view)
	gameView = game_view
	font = Theme:getFonts("mainMenuView")
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
	gyatt.frame("IRIZZ | SOUNDSPHERE", 0, -20, w, h, "center", "top")
	gfx.setFont(font.timeOfDay)
	gyatt.frame(Text.timeOfDay:format(getTimeOfDay()), 0, font.title:getHeight() - 20, w, h, "center", "top")
end

---@param screen_name string
function MainMenu:draw(screen_name)
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
