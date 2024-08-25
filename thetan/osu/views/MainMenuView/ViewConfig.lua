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
end

function ViewConfig:updateInfo(view)
	local chartview = view.game.selectModel.chartview

	now_playing = ("%s - %s"):format(chartview.artist, chartview.title)
end

local gfx = love.graphics
local parallax = 0.01

local function background()
	local w, h = Layout:move("base")
	local mx, my = love.mouse.getPosition()
	gfx.setColor(1, 1, 1)
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
local function button(image)
	gfx.draw(image)

	local mouse_over = gyatt.isOver(20, 20)
	gfx.translate(-32, 0)

	if gyatt.mousePressed(1) and mouse_over then
		return true
	end

	return false
end

local function header(view)
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
	local tw = font.info:getWidth(now_playing) * gyatt.getTextScale()
	gfx.translate(w - math_util.clamp(math.abs(-tw - 10 - 100), 0, 682), 0)
	gfx.draw(img.nowPlaying, 0, 0)
	gfx.translate(100, 4)
	gyatt.text(now_playing)
	gfx.pop()

	gfx.push()

	---@type audio.bass.BassSource
	local audio = view.game.previewModel.audio

	gfx.translate(w - 32, 36)

	button(img.musicList)
	button(img.musicInfo)

	if button(img.musicForwards) then
		view.game.selectModel:scrollNoteChartSet(1)
	end

	if button(img.musicToStart) then
		audio:setPosition(0)
	end

	if button(img.musicPause) then
		audio:pause()
	end

	if button(img.musicPlay) then
		audio:play()
	end

	if button(img.musicBackwards) then
		view.game.selectModel:scrollNoteChartSet(-1)
	end

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

	gfx.setColor(1, 1, 1, 0.7)
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

---@param view osu.MainMenuView
local function osuLogo(view)
	local w, h = Layout:move("base")

	local iw, ih = img.osuLogo:getDimensions()
	local mx, my = love.mouse.getPosition()
	local ax, ay = -mx * 0.005, -my * 0.005

	gfx.translate(w / 2 - iw / 2 + ax / 2 - (iw / 2 * beat), h / 2 - ih / 2 + ay / 2 - (ih / 2 * beat))
	gfx.draw(img.osuLogo, 0, 0, 0, 1 + beat, 1 + beat)

	if gyatt.mousePressed(1) and gyatt.isOver(iw, ih) then
		view:changeScreen("selectView")
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
	header(view)
	footer()
	osuDirect(view)
	osuLogo(view)
end

return ViewConfig
