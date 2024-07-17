local class = require("class")

local Layout = require("thetan.irizz.views.SelectView.SongSelect.OsuSongSelectLayout")

local OsuSongSelect = class()

local gyatt = require("thetan.gyatt")
local time_util = require("time_util")
local Format = require("sphere.views.Format")

local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")

local NoteChartSetListView = require("thetan.irizz.views.SelectView.OsuSongSelect.NoteChartSetListView")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect
local font

local assets = {}
local skin_path = "resources/osu_default_assets/"

local gfx = love.graphics

local avatar

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

function OsuSongSelect:new(game)
	avatar = Theme.avatarImage

	local content = love.filesystem.read(skin_path .. "skin.ini")

	if not content then
		return nil
	end

	content = utf8validate(content)
	assets.skinini = OsuNoteSkin:parseSkinIni(content)

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
	assets.forum = gfx.newImage(skin_path .. "rank-forum@2x.png")
	assets.noScores = gfx.newImage(skin_path .. "selection-norecords.png")

	assets.listButtonBackground = gfx.newImage(skin_path .. "menu-button-background@2x.png")
	assets.star = gfx.newImage(skin_path .. "star@2x.png")
	assets.maniaSmallIcon = gfx.newImage(skin_path .. "mode-mania-small@2x.png")

	font = Theme:getFonts("osuSongSelect")

	self.noteChartSetListView = NoteChartSetListView(game)
	self.noteChartSetListView:setAssets(assets)
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
	difficulty_str = ("%0.02f"):format(chartview.osu_diff or 0)

	username = view.game.configModel.configs.online.user.name or "Guest"
	is_logged_in = view.game.configModel.configs.online.user.name == nil

	local speedModel = view.game.speedModel
	local gameplay = view.game.configModel.configs.settings.gameplay
	scroll_speed_str = ("%i (fixed)"):format(speedModel.format[gameplay.speedType]:format(speedModel:get()))

	self.noteChartSetListView:reloadItems()
end

local function dropdown(label, w)
	local r, g, b, a = gfx.getColor()
	gfx.setColor({ 0, 0, 0, 0.5 })
	gfx.rectangle("fill", 0, 0, w, 22, 4, 4)

	gfx.setColor({ r, g, b, a })
	gfx.setLineWidth(1)
	gfx.rectangle("line", 0, 0, w, 22, 4, 4)

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
	gfx.translate(2, -5)
	gyatt.text(("Mapped by %s"):format(charter), w, "left")

	w, h = Layout:move("base")
	gfx.setFont(font.infoTop)

	gfx.translate(5, 38)
	gyatt.text(("Length: %s BPM: %s Objects %s"):format(length_str, bpm_str, objects_str), w, "left")
	gfx.setFont(font.infoCenter)
	gyatt.text(("Circles: %s Sliders: %s Spinners: 0"):format(note_count_str, ln_count_str))
	gfx.setFont(font.infoBottom)
	gyatt.text(("Keys: %s OD: 8 HP: 8 Star rating: %s"):format(columns_str, difficulty_str))

	w, h = Layout:move("base")
	gfx.translate(10, 120)
	gfx.setColor({ 0.08, 0.51, 0.7, 1 })
	dropdown("Local ranking", 305)

	gfx.translate(40, -5)
	gfx.draw(assets.forum)

	w, h = Layout:move("base")
	gfx.translate(801, 23)
	gfx.setFont(font.groupSort)
	gfx.setColor({ 0.57, 0.76, 0.9, 1 })
	gyatt.text("Group")
	gyatt.sameline()

	w, h = Layout:move("base")
	gfx.translate(1099, 23)
	gfx.setFont(font.groupSort)
	gfx.setColor({ 0.68, 0.82, 0.54, 1 })
	gyatt.text("Sort")

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

function OsuSongSelect:topUI()
	local w, h = Layout:move("base")
	gfx.translate(890, 29)
	gfx.setColor({ 0.57, 0.76, 0.9, 1 })
	dropdown("By Mode", 192)

	w, h = Layout:move("base")
	gfx.translate(1159, 29)
	gfx.setColor({ 0.68, 0.82, 0.54, 1 })
	dropdown("By Length", 192)

	w, h = Layout:move("base")
	gfx.setColor({ 1, 1, 1, 0.5 })
	gfx.setFont(font.scrollSpeed)
	gyatt.frame(scroll_speed_str, -15, 0, w, h, "right", "top")
end

local function bottomButtonImage(image)
	local _, ih = image:getDimensions()
	gfx.translate(0, -ih)
	gfx.draw(image)
	gfx.translate(0, ih)
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
	bottomButtonImage(assets.modeButton)
	gfx.translate(92, 0)

	bottomButtonImage(assets.modsButton)
	gfx.translate(77, 0)

	bottomButtonImage(assets.randomButton)
	gfx.translate(77, 0)

	bottomButtonImage(assets.optionsButton)

	w, h = Layout:move("base")
	gfx.translate(630, 693)

	iw, ih = avatar:getDimensions()
	gfx.draw(avatar, 0, 0, 0, 74 / iw, 74 / ih)

	gfx.translate(82, -4)
	gfx.setFont(font.username)
	gyatt.text(username)
	gfx.setFont(font.belowUsername)

	if not is_logged_in then
		gyatt.text("Click to sign in!")
	end

	gfx.translate(40, 40)

	gfx.setColor({ 0.15, 0.15, 0.15, 1 })
	gfx.rectangle("fill", 0, 0, 199, 12, 8, 8)

	gfx.setLineWidth(1)
	gfx.setColor({ 0.4, 0.4, 0.4, 1 })
	gfx.rectangle("line", 0, 0, 199, 12, 6, 6)
end

function OsuSongSelect:chartSetList()
	local w, h = Layout:move("base")
	local list = self.noteChartSetListView
	gfx.translate(756, 82)
	list:draw(610, 595, true)

	w, h = Layout:move("base")
	gfx.translate(756, 82)
	gyatt.scrollBar(list, 610, 595)
end

function OsuSongSelect:scores()
	local w, h = Layout:move("base")

	gfx.translate(20, 298)
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(assets.noScores)
end

function OsuSongSelect:logo()
	local w, h = Layout:move("base")
	local iw, ih = assets.osuLogo:getDimensions()

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.translate(w - (iw * 0.45) + 60, h - (ih * 0.45) + 60)
	gfx.scale(0.45)
	gfx.draw(assets.osuLogo)
	gfx.scale(1)
end

function OsuSongSelect:draw()
	Layout:draw()

	self:chartSetList()
	self:logo()
	self:top()
	self:bottom()
	self:topUI()
	self:scores()
end

return OsuSongSelect
