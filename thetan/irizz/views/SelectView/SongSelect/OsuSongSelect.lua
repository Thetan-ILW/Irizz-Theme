local class = require("class")

local Layout = require("thetan.irizz.views.SelectView.SongSelect.OsuSongSelectLayout")

local OsuSongSelect = class()

local gyatt = require("thetan.gyatt")
local time_util = require("time_util")
local math_util = require("math_util")
local table_util = require("table_util")
local Format = require("sphere.views.Format")

local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")

local NoteChartSetListView = require("thetan.irizz.views.SelectView.OsuSongSelect.NoteChartSetListView")
local ScoreListView = require("thetan.irizz.views.SelectView.OsuSongSelect.ScoreListView")

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
local scroll_speed_str = ""
local update_time = 0
local has_scores = false

local dropdowns = {
	scoreSource = {
		focus = false,
		updateTime = 0,
		selectedIndex = 1,
		format = "%s",
		mouseOver = false,
		items = {
			"Local ranking",
			"Online ranking",
			"osu! API ranking",
		},
	},
	group = {
		focus = false,
		updateTime = 0,
		selectedIndex = 1,
		format = "By %s",
		mouseOver = false,
		items = {
			"charts",
			"collections",
		},
	},
	sort = {
		focus = false,
		updateTime = 0,
		selectedIndex = 1,
		format = "By %s",
		mouseOver = false,
		items = {},
	},
}

function OsuSongSelect:new(game)
	avatar = Theme.avatarImage

	local content = love.filesystem.read(skin_path .. "skin.ini")

	if not content then
		error("No osu! skin selected")
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

	assets.gradeD = gfx.newImage(skin_path .. "ranking-D-small@2x.png")
	assets.gradeC = gfx.newImage(skin_path .. "ranking-C-small@2x.png")
	assets.gradeB = gfx.newImage(skin_path .. "ranking-B-small@2x.png")
	assets.gradeA = gfx.newImage(skin_path .. "ranking-A-small@2x.png")
	assets.gradeS = gfx.newImage(skin_path .. "ranking-S-small@2x.png")
	assets.gradeX = gfx.newImage(skin_path .. "ranking-X-small@2x.png")

	font = Theme:getFonts("osuSongSelect")

	self.noteChartSetListView = NoteChartSetListView(game)
	self.noteChartSetListView:setAssets(assets)

	self.scoreListView = ScoreListView(game)
	self.scoreListView:setAssets(assets)

	local sort_model = game.selectModel.sortModel
	dropdowns.sort.items = sort_model.names

	local sort_function = game.configModel.configs.select.sortFunction
	dropdowns.sort.selectedIndex = table_util.indexof(sort_model.names, sort_function)
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
	self.scoreListView:reloadItems()

	update_time = love.timer.getTime()

	has_scores = #view.game.selectModel.scoreLibrary.items ~= 0
end

local function animate(time, interval)
	local t = math.min(love.timer.getTime() - time, interval)
	local progress = t / interval
	return math_util.clamp(progress * progress, 0, 1)
end

local function dropdown(id, w)
	local instance = dropdowns[id]
	instance.mouseOver = false

	local r, g, b, a = gfx.getColor()
	gfx.push()
	gfx.setColor({ 0, 0, 0, 0.5 })
	gfx.rectangle("fill", 0, 0, w, 22, 4, 4)

	gfx.setColor({ r, g, b, a })
	gfx.setLineWidth(1)
	gfx.rectangle("line", 0, 0, w, 22, 4, 4)

	gfx.translate(3, -1)
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.setFont(font.dropdown)
	gyatt.text(instance.format:format(instance.items[instance.selectedIndex]), w, "left")

	gyatt.sameline()
	gfx.translate(w - 25, 4)
	gfx.draw(assets.dropdownArrow)
	gfx.pop()

	local just_opened = false

	local time = love.timer.getTime()

	if gyatt.mousePressed(1) then
		local open = gyatt.isOver(w, 22)

		if not instance.focus and open then
			instance.focus = true
			instance.updateTime = time
			just_opened = true
		elseif instance.focus and open then
			instance.focus = false
			instance.updateTime = time
		end
	end

	local changed = false
	local selected = 0

	local prev_canvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas(id .. "_dropdown")

	gfx.setCanvas({ canvas, stencil = true })
	gfx.clear()

	gfx.translate(0, 22)
	for i, v in ipairs(instance.items) do
		local mouse_over = gyatt.isOver(w, 27)

		if instance.focus then
			instance.mouseOver = instance.mouseOver or mouse_over
		end

		if mouse_over and gyatt.mousePressed(1) and instance.focus then
			selected = i
			changed = true
			instance.selectedIndex = i
			instance.focus = false
			instance.updateTime = time
		end

		gfx.push()

		gfx.setColor(mouse_over and { r, g, b, a } or { 0, 0, 0, 1 })
		gfx.rectangle("fill", 0, 0, w, 27, 4, 4)

		gfx.setColor({ 1, 1, 1, 1 })
		gfx.translate(10, 2)
		gyatt.text(instance.format:format(v))

		gfx.pop()

		gfx.translate(0, 27)
	end

	gfx.setCanvas({ prev_canvas, stencil = true })

	gfx.origin()
	a = animate(instance.updateTime, 0.15)

	if not instance.focus then
		a = 1 - a
	end

	gfx.setColor({ a, a, a, a })
	gfx.draw(canvas)

	if not changed and gyatt.mousePressed(1) and not just_opened and instance.focus then
		instance.focus = false
		instance.updateTime = time
	end

	return changed, selected
end

local function tab(label)
	gfx.setColor({ 0.86, 0.08, 0.23, 1 })
	gfx.draw(assets.tab)

	gfx.setColor({ 1, 1, 1, 1 })
	gyatt.frame(label, 0, 2, 137, 21, "center", "center")
end

function OsuSongSelect:chartInfo()
	local w, h = Layout:move("base")

	local a = animate(update_time, 0.3)

	gfx.setColor({ 1, 1, 1, a })
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
end

function OsuSongSelect:top()
	local w, h = Layout:move("base")

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(assets.panelTop)

	w, h = Layout:move("base")
	gfx.translate(10, 120)
	gfx.setColor({ 0.08, 0.51, 0.7, 1 })
	dropdown("scoreSource", 305)

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

function OsuSongSelect:topUI(view)
	local w, h = Layout:move("base")
	gfx.translate(890, 29)
	gfx.setColor({ 0.57, 0.76, 0.9, 1 })
	dropdown("group", 192)

	w, h = Layout:move("base")
	gfx.translate(1159, 29)
	gfx.setColor({ 0.68, 0.82, 0.54, 1 })
	local changed, index = dropdown("sort", 192)

	if changed then
		local sort_model = view.game.selectModel.sortModel
		local name = sort_model.names[index]

		if name then
			view.game.selectModel:setSortFunction(name)
		end
	end

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
	iw, ih = assets.osuLogo:getDimensions()

	gfx.setColor({ 1, 1, 1, 1 })
	gfx.translate(w - (iw * 0.45) + 60, h - (ih * 0.45) + 60)
	gfx.scale(0.45)
	gfx.draw(assets.osuLogo)
	gfx.scale(1)

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

	local no_focus = false

	for _, v in pairs(dropdowns) do
		no_focus = no_focus or v.mouseOver
	end

	list.focus = not no_focus

	gfx.translate(756, 82)
	list:draw(610, 595, true)

	w, h = Layout:move("base")
	gfx.translate(756, 82)
	gyatt.scrollBar(list, 610, 595)
end

function OsuSongSelect:scores(view)
	local list = self.scoreListView

	local no_focus = false

	for _, v in pairs(dropdowns) do
		no_focus = no_focus or v.mouseOver
	end

	list.focus = not no_focus

	local prev_canvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas("osuScoreList")
	gfx.setCanvas({ canvas, stencil = true })
	gfx.clear()

	local w, h = Layout:move("base")

	gfx.setBlendMode("alpha", "alphamultiply")

	if not has_scores then
		gfx.translate(20, 298)
		gfx.setColor({ 1, 1, 1, 1 })
		gfx.draw(assets.noScores)
	else
		gfx.translate(8, 154)

		list:draw(378, 420, true)
	end

	gfx.setCanvas({ prev_canvas, stencil = true })

	gfx.origin()
	gfx.setBlendMode("alpha", "premultiplied")
	local a = animate(update_time, 0.3)
	gfx.setColor(a, a, a, a)
	gfx.draw(canvas)
	gfx.setBlendMode("alpha")

	if list.openResult then
		list.openResult = false
		view:result()
	end
end

function OsuSongSelect:draw(view)
	Layout:draw()

	self:chartSetList()
	self:scores(view)
	self:top()
	self:bottom()
	self:chartInfo()
	self:topUI(view)
end

return OsuSongSelect
