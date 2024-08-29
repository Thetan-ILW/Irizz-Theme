local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.osu.views.OsuLayout")

local ui = require("thetan.osu.ui")
local flux = require("flux")
local gyatt = require("thetan.gyatt")
local time_util = require("time_util")
local math_util = require("math_util")
local loop = require("loop")
local gfx_util = require("gfx_util")
local map = require("math_util").map
local getBeatValue = require("thetan.osu.views.beat_value")

---@class osu.MainMenuViewConfig : IViewConfig
---@operator call: osu.MainMenuViewConfig
---@field hasFocus boolean
---@field mainButtonsTween table?
---@field playButtonsTween table?
---@field logoTween table?
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
local rate = 1

local update_time = 0
local menu_open_time = 0
local menu_button_update_time = 0
---@type "hidden" | "main" | "play"
local menu_state = "hidden"

---@type table<string, {image: love.Image, hoverImage: love.Image, y: number, animation: number}>
local buttons = {}

local gfx = love.graphics

---@type number[]
local smoothed_fft = {}
local smoothing_factor = 0.2

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

	self.mainButtonsAnimation = 0
	self.playButtonsAnimation = 0
	self.logoAnimation = 0

	self:createUiElements()

	for i = 1, 64 do
		smoothed_fft[i] = 0
	end
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
	---@type number
	rate = view.game.playContext.rate
end

local parallax = 0.01

---@param view osu.MainMenuView
local function background(view)
	local w, h = Layout:move("base")
	local mx, my = love.mouse.getPosition()
	gfx.setColor(0.9, 0.9, 0.9, 1)
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
end

local function copyright()
	local w, h = Layout:move("base")
	local ih = img.copyright:getHeight()
	gfx.draw(img.copyright, 4, h - ih - 4)
end

local logo = {
	x = 0,
	y = 0,
	focused = false,
}

function ViewConfig:processLogoState(view, event)
	if view.afkPercent == 0 then
		menu_state = "hidden"
	end

	local logo_click = event == "logo_click"

	if menu_state == "hidden" then
		if logo_click then
			menu_state = "main"
			if self.mainButtonsTween then
				self.mainButtonsTween:stop()
			end
			if self.logoTween then
				self.logoTween:stop()
			end
			self.mainButtonsTween = flux.to(self, 0.3, { mainButtonsAnimation = 1 }):ease("quadout")
			self.logoTween = flux.to(self, 0.3, { logoAnimation = 1 }):ease("quadout")
		end
	elseif menu_state == "main" then
		if self.mainButtonsAnimation == 0 then
			menu_state = "hidden"
		end
		if event == "hide" then
			if self.mainButtonsTween then
				self.mainButtonsTween:stop()
			end
			if self.logoTween then
				self.logoTween:stop()
			end
			self.mainButtonsTween = flux.to(self, 1, { mainButtonsAnimation = 0 }):ease("quadout")
			self.logoTween = flux.to(self, 1, { logoAnimation = 0 }):ease("quadout")
			menu_state = "hidden"
		elseif event == "switch_to_play" or logo_click then
			if self.mainButtonsTween then
				self.mainButtonsTween:stop()
			end
			if self.playButtonsTween then
				self.playButtonsTween:stop()
			end
			self.mainButtonsTween = flux.to(self, 0.3, { mainButtonsAnimation = 0 }):ease("quadout")
			self.playButtonsTween = flux.to(self, 0.3, { playButtonsAnimation = 1 }):ease("quadout")
			menu_state = "play"
		end
	elseif menu_state == "play" then
		if self.playButtonsAnimation == 0 then
			menu_state = "hidden"
		end
		if logo_click then
			view:changeScreen("selectView")
		end
		if event == "hide" then
			if self.playButtonsTween then
				self.playButtonsTween:stop()
			end
			if self.logoTween then
				self.logoTween:stop()
			end
			self.playButtonsTween = flux.to(self, 1, { playButtonsAnimation = 0 }):ease("quadout")
			self.logoTween = flux.to(self, 1, { logoAnimation = 0 }):ease("quadout")
			menu_state = "hidden"
		elseif event == "switch_to_main" then
			if self.mainButtonsTween then
				self.mainButtonsTween:stop()
			end
			if self.playButtonsTween then
				self.playButtonsTween:stop()
			end
			self.mainButtonsTween = flux.to(self, 0.3, { mainButtonsAnimation = 1 }):ease("quadout")
			self.playButtonsTween = flux.to(self, 0.3, { playButtonsAnimation = 0 }):ease("quadout")
			menu_state = "main"
		end
	end
end

---@param id string
---@param x number
---@param alpha number
function ViewConfig:logoButton(id, x, alpha)
	local btn = buttons[id]

	local pressed = false
	local hover = gyatt.isOver(580, 85, 0, btn.y) and not logo.focused and self.hasFocus

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

	gfx.setColor(1, 1, 1, alpha)
	gfx.draw(btn.image, x + (btn.animation * 20), btn.y)

	gfx.setColor(1, 1, 1, btn.animation * alpha)

	gfx.draw(btn.hoverImage, x + (btn.animation * 20), btn.y)
	gfx.setColor(1, 1, 1)

	return pressed
end

---@param view osu.MainMenuView
function ViewConfig:logoButtons(view)
	gfx.setScissor(gfx.getWidth() / 2, 0, gfx.getWidth() / 2, gfx.getHeight())

	local a = self.mainButtonsAnimation
	local x = 1 - a
	local focus = menu_state == "main" and self.mainButtonsAnimation > 0.05

	if self:logoButton("play", -300 * x, a) and focus then
		self:processLogoState(view, "switch_to_play")
	end

	if self:logoButton("edit", -300 * x, a) and focus then
		view:edit()
	end

	if self:logoButton("options", -300 * x, a) and focus then
		view:toggleSettings()
	end

	if self:logoButton("exit", -300 * x, a) and focus then
		view:closeGame()
		self:processLogoState(view, "hide")
	end

	a = self.playButtonsAnimation
	x = 1 - a
	focus = menu_state == "play" and self.playButtonsAnimation > 0.05

	if self:logoButton("solo", -300 * x, a) and focus then
		view:changeScreen("selectView")
	end

	if self:logoButton("multi", -300 * x, a) and focus then
	end

	if self:logoButton("back", -300 * x, a) and focus then
		self:processLogoState(view, "switch_to_main")
	end

	gfx.setScissor()
end

local num_rectangles = 256
local radius = 253
local rect_width = 5
local rect_height = 500
local current_rotation = 0

function ViewConfig:spectrum()
	local centerX, centerY = 0, 0

	for i = 1, num_rectangles do
		local angle = (i - 1) * (2 * math.pi / num_rectangles)

		local audio_value = smoothed_fft[1 + i % 64] * rect_height

		local base_x = centerX + radius * math.cos(angle)
		local base_y = centerY + radius * math.sin(angle)

		local tip_x = centerX + (radius + audio_value) * math.cos(angle)
		local tip_y = centerY + (radius + audio_value) * math.sin(angle)

		love.graphics.polygon(
			"fill",
			base_x - rect_width / 2 * math.sin(angle),
			base_y + rect_width / 2 * math.cos(angle),
			base_x + rect_width / 2 * math.sin(angle),
			base_y - rect_width / 2 * math.cos(angle),
			tip_x + rect_width / 2 * math.sin(angle),
			tip_y - rect_width / 2 * math.cos(angle),
			tip_x - rect_width / 2 * math.sin(angle),
			tip_y + rect_width / 2 * math.cos(angle)
		)
	end
end

---@param view osu.MainMenuView
function ViewConfig:osuLogo(view)
	local w, h = Layout:move("base")

	local iw, ih = img.osuLogo:getDimensions()
	local mx, my = getMousePosition()
	local ax, ay = -mx * 0.005, -my * 0.005

	local outro_scale = view.outroPercent * 0.3

	local sx = self.logoAnimation * 150

	logo.x = w / 2 - iw / 2 + ax / 2 - (iw / 2 * (beat - outro_scale)) - sx
	logo.y = h / 2 - ih / 2 + ay / 2 - (ih / 2 * (beat - outro_scale))

	local dx = (w / 2 - sx) - mx
	local dy = (h / 2) - my
	local distance = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

	logo.focused = distance < 255

	gfx.push()
	gfx.translate(w / 2 - sx, h / 2)
	gfx.scale(1 + beat - outro_scale, 1 + beat - outro_scale)

	gfx.push()
	self:logoButtons(view)
	gfx.pop()

	love.graphics.setColor(1, 1, 1, 0.65)
	gfx.translate(ax / 2, ay / 2)
	self:spectrum()
	gfx.scale(1)
	gfx.pop()

	gfx.setColor(1, 1, 1)

	gfx.translate(logo.x, logo.y)
	gfx.draw(img.osuLogo, 0, 0, 0, 1 + beat - outro_scale, 1 + beat - outro_scale)

	if gyatt.mousePressed(1) and logo.focused and self.hasFocus then
		self:processLogoState(view, "logo_click")
	end
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

local next_fft_time = -math.huge

local function updateFft(view)
	if love.timer.getTime() < next_fft_time then
		return
	end

	next_fft_time = love.timer.getTime() + 0.008

	---@type audio.bass.BassSource
	local audio = view.game.previewModel.audio

	if view.state == "intro" then
		audio = snd.welcome
		---@cast audio audio.bass.BassSource
	end

	if audio and audio.getData then
		local currentFft = audio:getData()
		beat = getBeatValue(currentFft)

		current_rotation = current_rotation + (beat * 100 * rate) * love.timer.getDelta()
		for i = 1, 64 do
			smoothed_fft[i] = smoothed_fft[i] * (1 - smoothing_factor)
				+ currentFft[(i - math.floor(current_rotation * 70)) % 64] * smoothing_factor
		end
	end
end

---@param view osu.MainMenuView
function ViewConfig:drawIntro(view)
	local prev_canvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas("osuMainMenu")

	gfx.setCanvas(canvas)

	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")

	background(view)
	self:header(view)
	footer()
	osuDirect(view)
	self:osuLogo(view)

	gfx.setCanvas({ prev_canvas, stencil = true })

	gfx.origin()
	local a = view.afkPercent
	gfx.setColor(a, a, a, a)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(canvas)
	gfx.setBlendMode("alpha")

	local scale = 0.75 + view.introPercent * 0.25
	local w, h = Layout:move("base")
	local iw, ih = img.welcomeText:getDimensions()
	iw, ih = iw * scale, ih * scale
	a = 1 - math.pow(view.introPercent, 8)

	gfx.push()
	gfx.translate(w / 2, h / 2)
	gfx.setColor(0, 0.09, 0.21, a)
	self:spectrum()
	gfx.pop()
	gfx.setColor(1, 1, 1, 1)
	copyright()
	gfx.setColor(1, 1, 1, a)
	gfx.draw(img.welcomeText, w / 2 - iw / 2, h / 2 - ih / 2, 0, scale, scale)
end

---@param view osu.MainMenuView
function ViewConfig:draw(view)
	Layout:draw()

	updateFft(view)

	if view.state == "intro" then
		self:drawIntro(view)
		return
	end

	background(view)

	local prev_canvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas("osuMainMenu")

	gfx.setCanvas(canvas)

	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")
	self:header(view)
	footer()

	gfx.setColor(1, 1, 1)
	copyright()
	osuDirect(view)

	gfx.setCanvas({ prev_canvas, stencil = true })

	gfx.origin()
	local a = view.afkPercent
	gfx.setColor(a, a, a, a)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(canvas)
	gfx.setBlendMode("alpha")

	self:processLogoState(view)
	self:osuLogo(view)
end

return ViewConfig
