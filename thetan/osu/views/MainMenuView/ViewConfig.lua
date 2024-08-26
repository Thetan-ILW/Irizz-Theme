local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.osu.views.OsuLayout")

local ui = require("thetan.osu.ui")
local gyatt = require("thetan.gyatt")
local time_util = require("time_util")
local math_util = require("math_util")
local loop = require("loop")
local gfx_util = require("gfx_util")
local map = require("math_util").map
local getBeatValue = require("thetan.osu.views.beat_value")

---@class osu.MainMenuViewConfig : IViewConfig
---@operator call: osu.MainMenuViewConfig
local ViewConfig = IViewConfig + {}

---@type table<string, string>
local text
---@type table<string, love.Font>
local font
---@type table<string, love.Image>
local img
---@type table<string, audio.Source>
local snd

local pp = 0
local accuracy = 0
local username = ""
local chart_count = 0
local beat = 0
local now_playing = ""

local update_time = 0
local menu_open_time = 0
local menu_button_update_time = 0
---@type "hidden" | "main" | "play"
local menu_state = "hidden"

---@type table<string, {image: love.Image, hoverImage: love.Image, y: number, animation: number}>
local buttons = {}

local gfx = love.graphics

---@param game sphere.GameController
---@param assets osu.OsuAssets
function ViewConfig:new(game, assets)
	img = assets.images
	snd = assets.sounds
	text, font = assets.localization:get("mainMenu")

	---@type skibidi.PlayerProfileModel
	local profile = game.playerProfileModel

	pp = profile.pp
	accuracy = profile.accuracy
	username = game.configModel.configs.online.user.name or "Guest"

	chart_count = #game.selectModel.noteChartSetLibrary.items
	update_time = math.huge
	menu_state = "hidden"

	self:createUiElements()
end

function ViewConfig:createUiElements()
	buttons.play = {
		image = img.menuPlayButton,
		hoverImage = img.menuPlayButtonHover,
		y = -200,
		animation = 0,
	}
	buttons.edit = {
		image = img.menuEditButton,
		hoverImage = img.menuEditButtonHover,
		y = -100,
		animation = 0,
	}
	buttons.options = {
		image = img.menuOptionsButton,
		hoverImage = img.menuOptionsButtonHover,
		y = 0,
		animation = 0,
	}
	buttons.exit = {
		image = img.menuExitButton,
		hoverImage = img.menuExitButtonHover,
		y = 100,
		animation = 0,
	}
	buttons.solo = {
		image = img.menuSoloButton,
		hoverImage = img.menuSoloButtonHover,
		y = -145,
		animation = 0,
	}
	buttons.multi = {
		image = img.menuMultiButton,
		hoverImage = img.menuMultiButtonHover,
		y = -42,
		animation = 0,
	}
	buttons.back = {
		image = img.menuBackButton,
		hoverImage = img.menuBackButtonHover,
		y = 60,
		animation = 0,
	}
end

local function getMousePosition()
	local w, h = love.mouse.getPosition()
	local scale = 768 / gfx.getHeight()
	return w * scale, h * scale
end

function ViewConfig:updateInfo(view)
	local chartview = view.game.selectModel.chartview

	now_playing = ("%s - %s"):format(chartview.artist, chartview.title)

	update_time = love.timer.getTime()
end

local parallax = 0.01

local function background()
	local w, h = Layout:move("base")
	local mx, my = love.mouse.getPosition()
	gfx.setColor(0.9, 0.9, 0.9)
	gfx_util.drawFrame(
		img.background,
		-map(mx, 0, w, parallax, 0) * w,
		-map(my, 0, h, parallax, 0) * h,
		(1 + 2 * parallax) * w,
		(1 + 2 * parallax) * h,
		"out"
	)
end

---@param image love.Image
---@return boolean
function ViewConfig:button(image)
	gfx.draw(image)

	local mouse_over = gyatt.isOver(20, 20)
	gfx.translate(-32, 0)

	if gyatt.mousePressed(1) and mouse_over then
		return self.hasFocus
	end

	return false
end

function ViewConfig:header(view)
	local w, h = Layout:move("base")

	gfx.setColor(0, 0, 0, 0.4)
	gfx.rectangle("fill", 0, 0, w, 86)

	gfx.push()
	gfx.translate(6, 6)
	local iw, ih = img.avatar:getDimensions()
	gfx.setColor(1, 1, 1)
	gfx.draw(img.avatar, 0, 0, 0, 74 / iw, 74 / ih)

	gfx.translate(80, -4)

	gfx.setFont(font.username)
	gyatt.text(username)
	gfx.setFont(font.belowUsername)

	gyatt.text(("Performance: %ipp\nAccuracy: %0.02f%%\nLv10"):format(pp, accuracy * 100))

	gfx.translate(40, 26)

	gfx.setColor({ 0.15, 0.15, 0.15, 1 })
	gfx.rectangle("fill", 0, 0, 199, 12, 8, 8)

	gfx.setLineWidth(1)
	gfx.setColor({ 0.4, 0.4, 0.4, 1 })
	gfx.rectangle("line", 0, 0, 199, 12, 6, 6)
	gfx.pop()

	gfx.translate(338, 6)
	gfx.setColor(1, 1, 1)
	gfx.setFont(font.info)

	local time = time_util.format(loop.time - loop.startTime)

	ui.textWithShadow(text.chartCount:format(chart_count))
	ui.textWithShadow(text.sessionTime:format(time))
	ui.textWithShadow(text.time:format(os.date("%H:%M")))

	w, h = Layout:move("base")

	gfx.push()

	local a = gyatt.easeOutCubic(update_time, 1)
	local tw = (font.info:getWidth(now_playing) * gyatt.getTextScale()) * a
	gfx.translate(w - math_util.clamp(math.abs(-tw - 10 - 100), 0, 682), 0)
	gfx.setColor(1, 1, 1, a)
	gfx.draw(img.nowPlaying, 0, 0)
	gfx.translate(100, 4)
	gyatt.text(now_playing)
	gfx.pop()

	gfx.push()

	---@type audio.bass.BassSource
	local audio = view.game.previewModel.audio

	gfx.translate(w - 32, 36)

	self:button(img.musicList)
	self:button(img.musicInfo)

	if self:button(img.musicForwards) then
		view.game.selectModel:scrollNoteChartSet(1)
	end

	if self:button(img.musicToStart) then
		audio:setPosition(0)
	end

	if self:button(img.musicPause) then
		audio:pause()
	end

	if self:button(img.musicPlay) then
		audio:play()
	end

	if self:button(img.musicBackwards) then
		view.game.selectModel:scrollNoteChartSet(-1)
	end
	gfx.setColor(1, 1, 1)

	gfx.pop()

	gfx.translate(w - 230, 64)

	if gyatt.mousePressed(1) and gyatt.isOver(200, 5) then
		local s = 1366 / gfx.getWidth()
		local click_percent = (love.mouse.getX() * s - (w - 230)) / 200
		audio:setPosition(click_percent * audio:getDuration())
	end

	local percent = 0

	if audio then
		percent = audio:getPosition() / audio:getDuration()
	end

	gfx.setColor(1, 1, 1, 0.7 * a)
	gfx.rectangle("fill", 0, 0, 200 * percent, 5)
end

local function footer()
	local w, h = Layout:move("base")

	gfx.setColor(0, 0, 0, 0.4)
	gfx.rectangle("fill", 0, h - 86, w, 86)

	gfx.setColor(1, 1, 1)
	local ih = img.copyright:getHeight()
	gfx.draw(img.copyright, 4, h - ih - 4)
end

local logo = {
	x = 0,
	y = 0,
	focused = false,
}

---@param view osu.MainMenuView
function ViewConfig:osuLogo(view)
	local w, h = Layout:move("base")

	local iw, ih = img.osuLogo:getDimensions()
	local mx, my = getMousePosition()
	local ax, ay = -mx * 0.005, -my * 0.005

	local sx = 0
	local open_a = (gyatt.easeOutCubic(menu_open_time, 0.4)) * view.afkPercent

	if menu_state ~= "hidden" then
		sx = 150 * open_a
	end

	logo.x = w / 2 - iw / 2 + ax / 2 - (iw / 2 * beat) - sx
	logo.y = h / 2 - ih / 2 + ay / 2 - (ih / 2 * beat)

	local dx = (w / 2 - sx) - mx
	local dy = (h / 2) - my
	local distance = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

	logo.focused = distance < 255

	if view.afkPercent == 0 then
		menu_state = "hidden"
	end

	gfx.translate(logo.x, logo.y)
	gfx.setColor(1, 1, 1)
	gfx.draw(img.osuLogo, 0, 0, 0, 1 + beat, 1 + beat)

	if gyatt.mousePressed(1) and logo.focused and self.hasFocus then
		if menu_state == "hidden" then
			menu_open_time = love.timer.getTime()
			menu_button_update_time = love.timer.getTime()
			menu_state = "main"
		elseif menu_state == "main" then
			menu_state = "play"
			menu_button_update_time = love.timer.getTime()
		elseif menu_state == "play" then
			view:changeScreen("selectView")
		end
	end
end

---@param id string
---@param x number
function ViewConfig:logoButton(id, x)
	local btn = buttons[id]

	local pressed = false
	local hover = gyatt.isOver(400, 85, 0, btn.y) and not logo.focused and self.hasFocus

	local dt = love.timer.getDelta()

	if hover then
		btn.animation = btn.animation + dt * 8

		if gyatt.mousePressed(1) then
			pressed = true
		end
	else
		btn.animation = btn.animation - dt * 8
	end

	btn.animation = math_util.clamp(btn.animation, 0, 1)

	gfx.draw(btn.image, x + (btn.animation * 20), btn.y)

	gfx.setColor(1, 1, 1, btn.animation)

	gfx.draw(btn.hoverImage, x + (btn.animation * 20), btn.y)
	gfx.setColor(1, 1, 1)

	return pressed
end

---@param view osu.MainMenuView
function ViewConfig:logoButtons(view)
	local w, h = Layout:move("base")
	local buttons_a = (gyatt.easeOutCubic(menu_button_update_time, 0.4)) * view.afkPercent
	local bx = 0

	if menu_state ~= "hidden" then
		bx = 150 * buttons_a
	end

	gfx.setScissor(gfx.getWidth() / 2, 0, gfx.getWidth() / 2, gfx.getHeight())
	gfx.translate(w / 2, h / 2)
	gfx.setColor(1, 1, 1, buttons_a)

	if menu_state == "main" then
		if self:logoButton("play", -300 + bx) then
			menu_state = "play"
			menu_button_update_time = love.timer.getTime()
		end

		if self:logoButton("edit", -300 + bx) then
			view:edit()
		end

		if self:logoButton("options", -300 + bx) then
			view:openModal("thetan.irizz.views.modals.SettingsModal")
		end

		if self:logoButton("exit", -300 + bx) then
			love.event.quit()
		end
	elseif menu_state == "play" then
		if self:logoButton("solo", -300 + bx) then
			view:changeScreen("selectView")
		end

		self:logoButton("multi", -300 + bx)

		if self:logoButton("back", -300 + bx) then
			menu_state = "main"
			menu_button_update_time = love.timer.getTime()
		end
	end

	gfx.setScissor()
end

local direct_button = {
	mouseOver = false,
	updateTime = -math.huge,
}

local function osuDirect(view)
	local w, h = Layout:move("base")

	local iw, ih = img.directButton:getDimensions()

	gfx.setColor(1, 1, 1)
	gfx.translate(w - iw, h / 2 - ih / 2)

	if gyatt.isOver(iw, ih) and not direct_button.mouseOver then
		direct_button.updateTime = love.timer.getTime()
		direct_button.mouseOver = true
	elseif not gyatt.isOver(iw, ih) and direct_button.mouseOver then
		direct_button.updateTime = love.timer.getTime()
		direct_button.mouseOver = false
	end

	gfx.draw(img.directButton)

	local a = math_util.clamp(love.timer.getTime() - direct_button.updateTime, 0, 0.1) * 10

	a = direct_button.mouseOver and a or 1 - a

	gfx.setColor(1, 1, 1, a)

	gfx.draw(img.directButtonOver)
	gfx.setColor(1, 1, 1)
end

local function updateBeat(view)
	---@type audio.bass.BassSource
	local audio = view.game.previewModel.audio

	if audio and audio.getData then
		beat = getBeatValue(audio:getData())
	end
end

---@param view osu.MainMenuView
function ViewConfig:draw(view)
	Layout:draw()

	updateBeat(view)

	background()

	local prev_canvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas("osuMainMenu")

	gfx.setCanvas(canvas)

	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")
	self:header(view)
	footer()
	osuDirect(view)

	gfx.setCanvas({ prev_canvas, stencil = true })

	gfx.origin()
	local a = view.afkPercent
	gfx.setColor(a, a, a, a)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(canvas)
	gfx.setBlendMode("alpha")
	gfx.setColor(1, 1, 1)

	self:logoButtons(view)
	self:osuLogo(view)
end

return ViewConfig
