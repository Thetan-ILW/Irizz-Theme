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
local Text = Theme.textSongSelect
local font

local assets = {}
local skin_path = "resources/osu_default_assets/"

local gfx = love.graphics

local avatar
local top_panel_quad
local brighten_shader

local prev_chart_id = 0
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
local mods_str = ""
local current_time = 0
local update_time = 0
local chart_list_update_time = 0
local has_scores = false

local white = { 1, 1, 1, 1 }

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

local buttons = {
	back = {
		updateTime = 0,
		mouseOver = false,
		rect = { 0, -90, 200, 90 },
	},
	mode = {
		updateTime = 0,
		mouseOver = false,
		rect = { 0, -90, 88, 90 },
	},
	mods = {
		updateTime = 0,
		mouseOver = false,
		rect = { 0, -90, 74, 90 },
	},
	random = {
		updateTime = 0,
		mouseOver = false,
		rect = { 0, -90, 74, 90 },
	},
	chartOptions = {
		updateTime = 0,
		mouseOver = false,
		rect = { 0, -90, 74, 90 },
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
	assets.panelTop:setWrap("clamp")

	assets.panelBottom = gfx.newImage(skin_path .. "songselect-bottom.png")
	assets.rankedIcon = gfx.newImage(skin_path .. "selection-ranked@2x.png")
	assets.dropdownArrow = gfx.newImage(skin_path .. "dropdown-arrow.png")

	assets.menuBack = gfx.newImage(skin_path .. "menu-back@2x.png")
	assets.modeButton = gfx.newImage(skin_path .. "selection-mode@2x.png")
	assets.modsButton = gfx.newImage(skin_path .. "selection-mods@2x.png")
	assets.randomButton = gfx.newImage(skin_path .. "selection-random@2x.png")
	assets.optionsButton = gfx.newImage(skin_path .. "selection-options@2x.png")

	assets.modeButtonOver = gfx.newImage(skin_path .. "selection-mode-over@2x.png")
	assets.modsButtonOver = gfx.newImage(skin_path .. "selection-mods-over@2x.png")
	assets.randomButtonOver = gfx.newImage(skin_path .. "selection-random-over@2x.png")
	assets.optionsButtonOver = gfx.newImage(skin_path .. "selection-options-over@2x.png")

	assets.osuLogo = gfx.newImage(skin_path .. "menu-osu@2x.png")
	assets.tab = gfx.newImage(skin_path .. "selection-tab@2x.png")
	assets.forum = gfx.newImage(skin_path .. "rank-forum@2x.png")
	assets.noScores = gfx.newImage(skin_path .. "selection-norecords.png")

	assets.listButtonBackground = gfx.newImage(skin_path .. "menu-button-background@2x.png")
	assets.star = gfx.newImage(skin_path .. "star@2x.png")
	assets.maniaSmallIcon = gfx.newImage(skin_path .. "mode-mania-small@2x.png")
	assets.maniaSmallIconForCharts = gfx.newImage(skin_path .. "mode-mania-small-for-charts@2x.png")
	assets.maniaIcon = gfx.newImage(skin_path .. "mode-mania@2x.png")

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

	local shaders = require("irizz.shaders")
	brighten_shader = shaders.brighten

	Layout:draw()

	chart_list_update_time = love.timer.getTime() + 0.4
	self:resolutionUpdated()
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

	has_scores = #view.game.selectModel.scoreLibrary.items ~= 0

	if prev_chart_id ~= chartview.id then
		update_time = current_time
	end

	prev_chart_id = chartview.id
end

local function animate(time, interval)
	local t = math.min(current_time - time, interval)
	local progress = t / interval
	return math_util.clamp(progress * progress, 0, 1)
end

local function easeOutCubic(time, interval)
	local t = math.min(current_time - time, interval)
	local progress = t / interval
	return math_util.clamp(1 - math.pow(1 - progress, 3), 0, 1)
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
	gfx.setColor(white)
	gfx.setFont(font.dropdown)
	gyatt.text(instance.format:format(instance.items[instance.selectedIndex]), w, "left")

	gyatt.sameline()
	gfx.translate(w - 25, 4)
	gfx.draw(assets.dropdownArrow)
	gfx.pop()

	local just_opened = false

	local time = current_time

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

	a = easeOutCubic(instance.updateTime, 0.35)

	if not instance.focus then
		a = 1 - a
	end

	if a == 0 then
		return
	end

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

		gfx.setColor(mouse_over and { r, g, b, 1 } or { 0, 0, 0, 1 })
		gfx.rectangle("fill", 0, 0, w, 27, 4, 4)

		gfx.setColor(white)
		gfx.translate(10, 2)
		gyatt.text(instance.format:format(v))

		gfx.pop()

		gfx.translate(0, 27 * a)
	end

	gfx.setCanvas({ prev_canvas, stencil = true })

	gfx.origin()

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

	gfx.setColor(white)
	gyatt.frame(label, 0, 2, 137, 21, "center", "center")
end

function OsuSongSelect:chartInfo()
	local w, h = Layout:move("base")

	local a = animate(update_time, 0.2)
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
	a = animate(update_time, 0.3)
	gfx.setColor({ 1, 1, 1, a })
	gyatt.text(("Length: %s BPM: %s Objects %s"):format(length_str, bpm_str, objects_str), w, "left")

	a = animate(update_time, 0.4)
	gfx.setColor({ 1, 1, 1, a })
	gfx.setFont(font.infoCenter)
	gyatt.text(("Circles: %s Sliders: %s Spinners: 0"):format(note_count_str, ln_count_str))

	a = animate(update_time, 0.5)
	gfx.setColor({ 1, 1, 1, a })
	gfx.setFont(font.infoBottom)
	gyatt.text(("Keys: %s OD: 8 HP: 8 Star rating: %s"):format(columns_str, difficulty_str))
end

function OsuSongSelect:top()
	local w, h = Layout:move("base")

	local a = math_util.clamp((1 - easeOutCubic(update_time, 1)) * 0.15, 0, 0.10)

	local prev_shader = gfx.getShader()

	gfx.setShader(brighten_shader)
	brighten_shader:send("amount", a)
	gfx.setColor(white)
	gfx.draw(assets.panelTop, top_panel_quad)
	gfx.setShader(prev_shader)

	w, h = Layout:move("base")
	gfx.translate(w - 570, 23)
	gfx.setFont(font.groupSort)
	gfx.setColor({ 0.57, 0.76, 0.9, 1 })
	gyatt.text("Group")
	gyatt.sameline()

	w, h = Layout:move("base")
	gfx.translate(w - 270, 23)
	gfx.setFont(font.groupSort)
	gfx.setColor({ 0.68, 0.82, 0.54, 1 })
	gyatt.text("Sort")
end

function OsuSongSelect:topUI(view)
	local w, h = Layout:move("base")
	gfx.translate(10, 120)
	gfx.setColor({ 0.08, 0.51, 0.7, 1 })
	dropdown("scoreSource", 305)

	w, h = Layout:move("base")
	gfx.setColor(white)
	gfx.translate(331, 118)
	gfx.draw(assets.forum)

	if gyatt.isOver(23, 23) and gyatt.mousePressed(1) then
		love.system.openURL("https://soundsphere.xyz/notecharts")
		view.gameView.showMessage("Opening the link. Check your browser.", nil, { show_time = 3 })
	end

	w, h = Layout:move("base")
	gfx.setColor({ 1, 1, 1, 0.5 })
	gfx.setFont(font.scrollSpeed)
	gyatt.frame(scroll_speed_str, -15, 0, w, h, "right", "top")

	w, h = Layout:move("base")
	gfx.setFont(font.tabs)
	gfx.translate(w - 632, 54)
	tab("Collections")
	gfx.translate(118, 0)
	tab("Recently played")
	gfx.translate(118, 0)
	tab("By Artist")
	gfx.translate(118, 0)
	tab("By Difficulty")
	gfx.translate(118, 0)
	tab("No grouping")

	w, h = Layout:move("base")
	gfx.translate(w - 479, 29)
	gfx.setColor({ 0.57, 0.76, 0.9, 1 })
	dropdown("group", 192)

	w, h = Layout:move("base")
	gfx.translate(w - 210, 29)
	gfx.setColor({ 0.68, 0.82, 0.54, 1 })
	local changed, index = dropdown("sort", 192)

	if changed then
		local sort_model = view.game.selectModel.sortModel
		local name = sort_model.names[index]

		if name then
			view.game.selectModel:setSortFunction(name)
		end
	end
end

local function bottomButtonImage(id, image, mouse_over_image)
	local instance = buttons[id]
	local rect = instance.rect
	local mouse_over = gyatt.isOver(rect[3], rect[4], rect[1], rect[2])
	instance.mouseOver = mouse_over

	local _, ih = image:getDimensions()
	gfx.translate(0, -ih)
	gfx.setColor(white)
	gfx.draw(image)
	gfx.translate(0, ih)

	local pressed = false

	if mouse_over then
		instance.updateTime = current_time

		if gyatt.mousePressed(1) then
			pressed = true
		end
	end

	local a = 1 - animate(instance.updateTime, 0.4)

	_, ih = mouse_over_image:getDimensions()
	gfx.translate(0, -ih)
	gfx.setColor({ a, a, a, a })
	gfx.setBlendMode("add")
	gfx.draw(mouse_over_image)
	gfx.setBlendMode("alpha")
	gfx.translate(0, ih)

	return pressed
end

function OsuSongSelect:bottom(view)
	local w, h = Layout:move("base")

	gfx.setColor(white)

	local iw, ih = assets.panelBottom:getDimensions()

	local a = math_util.clamp((1 - easeOutCubic(update_time, 1)) * 0.15, 0, 0.1)

	local prev_shader = gfx.getShader()

	gfx.setShader(brighten_shader)
	gfx.translate(0, h - ih)
	gfx.draw(assets.panelBottom, 0, 0, 0, w / iw, 1)
	gfx.setShader(prev_shader)

	w, h = Layout:move("base")
	iw, ih = assets.osuLogo:getDimensions()

	gfx.setColor(white)
	gfx.translate(w - (iw * 0.45) + 60, h - (ih * 0.45) + 60)
	gfx.scale(0.45)
	gfx.draw(assets.osuLogo)
	gfx.scale(1)

	w, h = Layout:move("base")
	gfx.translate(0, h)
	bottomButtonImage("back", assets.menuBack, assets.menuBack)

	w, h = Layout:move("bottomButtons")
	bottomButtonImage("mode", assets.modeButton, assets.modeButtonOver)

	iw, ih = assets.maniaSmallIcon:getDimensions()
	gfx.translate(-iw / 2 + 45, -ih / 2 - 55)
	gfx.setColor(white)
	gfx.draw(assets.maniaSmallIcon)
	gfx.translate(iw / 2 - 45, ih / 2 + 55)

	gfx.translate(92, 0)

	if bottomButtonImage("mods", assets.modsButton, assets.modsButtonOver) then
		view:openModal("thetan.irizz.views.modals.ModifierModal")
	end

	gfx.translate(77, 0)

	if bottomButtonImage("random", assets.randomButton, assets.randomButtonOver) then
		view.selectModel:scrollRandom()
	end

	gfx.translate(77, 0)

	if bottomButtonImage("chartOptions", assets.optionsButton, assets.optionsButtonOver) then
		view:openModal("thetan.irizz.views.modals.MountsModal")
	end

	w, h = Layout:move("base")
	gfx.translate(630, 693)

	iw, ih = avatar:getDimensions()
	gfx.setColor(white)
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

	local a = easeOutCubic(chart_list_update_time, 0.7)

	gfx.translate(w - (610 * a), 82)
	list:updateAnimations()
	list:draw(610, 595, true)

	w, h = Layout:move("base")
	gfx.translate(w - 610, 82)
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
		list:updateAnimations()
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

function OsuSongSelect:mods(view)
	local w, h = Layout:move("base")

	gfx.translate(104, 633)
	gfx.setColor({ 1, 1, 1, 0.75 })
	gfx.setFont(font.mods)
	gyatt.text(mods_str)
end

function OsuSongSelect:updateOtherInfo(view)
	local modifiers = view.game.playContext.modifiers
	mods_str = Theme:getModifierString(modifiers)

	local rate = view.game.playContext.rate
	local rate_type = view.game.configModel.configs.settings.gameplay.rate_type
	local time_rate_model = view.game.timeRateModel

	if rate ~= 1 then
		local rate_str

		if rate_type == "linear" then
			rate_str = ("%0.02fx"):format(time_rate_model:get())
		else
			rate_str = ("%iQ"):format(time_rate_model:get())
		end

		mods_str = rate_str .. " " .. mods_str
	end
end

function OsuSongSelect:modeLogo()
	local w, h = Layout:move("base")
	local image = assets.maniaIcon
	local iw, ih = image:getDimensions()

	gfx.translate(w / 2 - iw / 2, h / 2 - ih / 2)
	gfx.setColor({ 1, 1, 1, 0.2 })
	gfx.draw(image)
end

function OsuSongSelect:resolutionUpdated()
	local w, h = Layout:move("base")
	top_panel_quad = gfx.newQuad(0, 0, w, assets.panelTop:getHeight(), assets.panelTop)
end

function OsuSongSelect:draw(view)
	Layout:draw()

	current_time = love.timer.getTime()
	self:updateOtherInfo(view)

	self:modeLogo()
	self:chartSetList()
	self:scores(view)
	self:top()
	self:bottom(view)
	self:chartInfo()
	self:topUI(view)
	self:mods(view)
	--print(view.game.chartPreviewModel.graphicEngine.renderer.cvp[1].point:getBeatModulo())
end

return OsuSongSelect
