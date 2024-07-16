local class = require("class")

local Layout = require("thetan.irizz.views.SelectView.SongSelect.OsuSongSelectLayout")

local OsuSongSelect = class()

local gyatt = require("thetan.gyatt")
local time_util = require("time_util")
local Format = require("sphere.views.Format")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect
local font

local assets = {}
local skin_path = "resources/osu_default_assets/"

local gfx = love.graphics

local chart_name = ""
local charter = ""
local length_str = ""
local bpm_str = ""
local objects_str = ""
local ln_count_str = ""
local note_count_str = ""
local columns_str = ""
local difficulty_str = ""
local username = ""
local is_logged_in = false
local pp = ""
local scroll_speed_str = ""

function OsuSongSelect:new()
	assets.panelTop = gfx.newImage(skin_path .. "songselect-top.png")
	assets.panelBottom = gfx.newImage(skin_path .. "songselect-bottom.png")
	assets.rankedIcon = gfx.newImage(skin_path .. "selection-ranked@2x.png")
	assets.dropdownArrow = gfx.newImage(skin_path .. "dropdown-arrow.png")

	assets.menuBack = gfx.newImage(skin_path .. "menu-back@2x.png")
	assets.modeButton = gfx.newImage(skin_path .. "selection-mode@2x.png")
	assets.modsButton = gfx.newImage(skin_path .. "selection-mods@2x.png")
	assets.randomButton = gfx.newImage(skin_path .. "selection-random@2x.png")
	assets.optionsButton = gfx.newImage(skin_path .. "selection-options@2x.png")
	assets.osuLogo = gfx.newImage(skin_path .. "menu-osu@2x.png")
	assets.tab = gfx.newImage(skin_path .. "selection-tab@2x.png")

	font = Theme:getFonts("osuSongSelect")
end

function OsuSongSelect:updateInfo(view)
	local chartview = view.game.selectModel.chartview
	local rate = view.game.playContext.rate

	if not chartview then
		return
	end

	chart_name = string.format("%s - %s [%s]", chartview.artist, chartview.title, chartview.name)
	charter = chartview.creator

	local note_count = chartview.notes_count or 0
	local ln_count = chartview.long_notes_count or 0

	length_str = time_util.format((chartview.duration or 0) / rate)
	bpm_str = ("%i"):format((chartview.tempo or 0) * rate)
	objects_str = tostring(note_count + ln_count)
	note_count_str = tostring(note_count or 0)
	ln_count_str = tostring(ln_count or 0)

	columns_str = Format.inputMode(chartview.chartdiff_inputmode)
	difficulty_str = ("%0.02f"):format(chartview.osu_diff)

	username = view.game.configModel.configs.online.user.name or "Guest"
	is_logged_in = view.game.configModel.configs.online.user.name == nil

	local speedModel = view.game.speedModel
	local gameplay = view.game.configModel.configs.settings.gameplay
	scroll_speed_str = ("%i (fixed)"):format(speedModel.format[gameplay.speedType]:format(speedModel:get()))
end

local function dropdown(label, w)
	gfx.setLineWidth(1)
	gfx.rectangle("line", 0, 0, w, 24, 4, 4)

	gfx.translate(3, -1)
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.setFont(font.dropdown)
	gyatt.text(label, w, "left")

	gyatt.sameline()
	gfx.translate(w - 25, 4)
	gfx.draw(assets.dropdownArrow)
end

local function tab(label)
	gfx.setColor({ 0.86, 0.08, 0.23, 1 })
	gfx.draw(assets.tab)

	gfx.setColor({ 1, 1, 1, 1 })
	gyatt.frame(label, 0, 2, 137, 21, "center", "center")
end

function OsuSongSelect:top()
	local w, h = Layout:move("base")

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(assets.panelTop)

	gfx.translate(5, 5)
	gfx.draw(assets.rankedIcon)
	gfx.translate(-5, -5)

	gfx.setFont(font.chartName)
	gfx.translate(38, -6)
	gyatt.text(chart_name, w, "left")

	gfx.setFont(font.chartedBy)
	gfx.translate(0, -5)
	gyatt.text(("Mapped by %s"):format(charter), w, "left")

	w, h = Layout:move("base")
	gfx.setFont(font.infoTop)

	gfx.translate(5, 38)
	gyatt.text(("Length: %s BPM: %s Objects %s"):format(length_str, bpm_str, objects_str), w, "left")
	gyatt.text(("Circles: %s Sliders: %s Spinners: 0"):format(note_count_str, ln_count_str))
	gfx.setFont(font.infoBottom)
	gyatt.text(("Keys: %s OD: 8 HP: 8 Star rating: %s"):format(columns_str, difficulty_str))

	w, h = Layout:move("base")
	gfx.translate(10, 116)
	gfx.setColor({ 0.08, 0.51, 0.7, 1 })
	dropdown("Local ranking", 307)

	w, h = Layout:move("base")
	gfx.translate(801, 23)
	gfx.setFont(font.groupSort)
	gfx.setColor({ 0.57, 0.76, 0.9, 1 })
	gyatt.text("Group")
	gyatt.sameline()
	gfx.translate(89, 4)
	dropdown("By Mode", 192)

	w, h = Layout:move("base")
	gfx.translate(1099, 23)
	gfx.setFont(font.groupSort)
	gfx.setColor({ 0.68, 0.82, 0.54, 1 })
	gyatt.text("Sort")
	gyatt.sameline()
	gfx.translate(60, 4)
	dropdown("By Length", 192)

	w, h = Layout:move("base")
	gfx.setColor({ 0.25, 0.25, 0.25, 1 })
	gfx.setFont(font.scrollSpeed)
	gyatt.frame(scroll_speed_str, -15, 0, w, h, "right", "top")

	w, h = Layout:move("base")
	gfx.setFont(font.tabs)
	gfx.translate(736, 54)
	tab("Collections")
	gfx.translate(118, 0)
	tab("Recently played")
	gfx.translate(118, 0)
	tab("By Artist")
	gfx.translate(118, 0)
	tab("By Difficulty")
	gfx.translate(118, 0)
	tab("No grouping")
end

function OsuSongSelect:bottom()
	local w, h = Layout:move("base")

	gfx.setColor({ 1, 1, 1, 1 })

	local iw, ih = assets.panelBottom:getDimensions()

	gfx.translate(0, h - ih)
	gfx.draw(assets.panelBottom, 0, 0, 0, w / iw, 1)

	w, h = Layout:move("base")
	iw, ih = assets.menuBack:getDimensions()

	gfx.translate(0, h - ih)
	gfx.draw(assets.menuBack)

	w, h = Layout:move("bottomButtons")
	gfx.draw(assets.modeButton)

	gfx.translate(92, 0)
	gfx.draw(assets.modsButton)

	gfx.translate(77, 0)
	gfx.draw(assets.randomButton)

	gfx.translate(77, 0)
	gfx.draw(assets.optionsButton)

	gfx.translate(240, 15)
	gfx.setFont(font.username)
	gyatt.text(username)
	gfx.setFont(font.belowUsername)
	gyatt.text("Click to sign in!")

	gfx.translate(40, 20)

	gfx.setColor({ 0.15, 0.15, 0.15, 1 })
	gfx.rectangle("fill", 0, 0, 199, 12, 8, 8)

	gfx.setLineWidth(1)
	gfx.setColor({ 0.4, 0.4, 0.4, 1 })
	gfx.rectangle("line", 0, 0, 199, 12, 6, 6)

	w, h = Layout:move("base")
	iw, ih = assets.osuLogo:getDimensions()

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.translate(w - (iw * 0.45) + 60, h - (ih * 0.45) + 60)
	gfx.scale(0.45)
	gfx.draw(assets.osuLogo)
	gfx.scale(1)
end

function OsuSongSelect:draw()
	Layout:draw()

	self:top()
	self:bottom()
end

return OsuSongSelect
