local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.osu.views.OsuLayout")

local ui = require("thetan.osu.ui")
local gyatt = require("thetan.gyatt")
local time_util = require("time_util")
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

local function header()
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
	header()
	footer()
	osuLogo(view)
end

return ViewConfig
