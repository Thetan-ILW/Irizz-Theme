local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")
local gfx_util = require("gfx_util")
local time_util = require("time_util")
local math_util = require("math_util")

local TextInput = require("thetan.irizz.imgui.TextInput")

local Format = require("sphere.views.Format")
local Layout = require("thetan.irizz.views.SelectView.SongSelect.SongSelectLayout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect
local font

local NoteChartSetListView = require("thetan.irizz.views.SelectView.SongSelect.NoteChartSetListView")
local NoteChartListView = require("thetan.irizz.views.SelectView.SongSelect.NoteChartListView")
local ScoreListView = require("thetan.irizz.views.ScoreListView")
local OsuScoreListView = require("thetan.irizz.views.OsuScoreList")

local boxes = {
	"scores",
	"infoAndMods",
	"column2",
	"difficultyAndInfo",
	"charts",
}

local ViewConfig = class()

---@type irizz.ActionModel
local actionModel

local canUpdate = false

function ViewConfig:new(game)
	actionModel = game.actionModel
	self.noteChartSetListView = NoteChartSetListView(game)
	self.noteChartListView = NoteChartListView(game)
	self.scoreListView = ScoreListView(game)
	self.osuScoreListView = OsuScoreListView(game)
	font = Theme:getFonts("songSelectViewConfig")
end

local diffColumn = ""
local difficultyValue = 0
local patterns = ""
local calculator = ""
local difficultyColor = Color.text
local longNoteRatio = 0

function ViewConfig:updateInfo(view)
	local chartview = view.game.selectModel.chartview
	local timeRate = view.game.playContext.rate

	if not chartview then
		return
	end

	diffColumn = view.game.configModel.configs.settings.select.diff_column
	local diff = (chartview.difficulty or 0)
	difficultyValue = diff * timeRate
	patterns = chartview.level and "Lv." .. chartview.level or Text.noPatterns

	if diffColumn == "msd_diff" and chartview.msd_diff_data then
		local msd = Theme.getMsdFromData(chartview.msd_diff_data, timeRate)

		if msd then
			difficultyValue = msd.overall
			patterns = Theme.getMaxAndSecondFromMsd(msd) or Text.noPatterns
		end
	end

	difficultyColor = Theme:getDifficultyColor(difficultyValue, diffColumn)
	calculator = Theme.formatDiffColumns(diffColumn)

	if chartview.notes_count and chartview.notes_count ~= 0 then
		longNoteRatio = ((chartview.long_notes_count or 0) / chartview.notes_count) * 100
	end

	self.noteChartListView:reloadItems()
	self.noteChartSetListView:reloadItems()
	self.scoreListView:reloadItems()
end

function ViewConfig.panels()
	for _, name in pairs(boxes) do
		local w, h = Layout:move(name)
		Theme:panel(w, h)
	end
end

local function borders()
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)

	for i, name in pairs(boxes) do
		local w, h = Layout:move(name)
		Theme:border(w, h)
	end
end

---@param view table
local function searchField(view)
	local vimMotions = actionModel.isVimMode()

	if not vimMotions or actionModel.isInsertMode() then
		just.focus("SearchField")
	end

	local w, h = Layout:move("search")

	local config = view.game.configModel.configs.select

	love.graphics.setFont(font.searchField)
	local changed, text = TextInput("SearchField", { config.filterString, Text.searchPlaceholder }, nil, w, h)

	if changed == "text" then
		view:updateSearch(text)
	end

	local delAll = actionModel.consumeAction("deleteLine")

	if delAll then
		view:updateSearch("")
	end

	w, h = Layout:move("search")
	love.graphics.setFont(font.filterLine)
	Theme:textWithShadow(view.chartFilterLine, w, h, "center", "bottom")

	if just.button("filterLineButton", just.is_over(w, h)) then
		view:openModal("thetan.irizz.views.modals.FiltersModal")
	end
end

function ViewConfig:noteChartSets(view)
	local w, h = Layout:move("column2")

	local list = self.noteChartSetListView
	list:draw(w, h, canUpdate)

	gyatt.scrollBar(list, w, h)
end

---@param view table
function ViewConfig:noteChartList(view)
	local w, h = Layout:move("charts")

	local list = self.noteChartListView
	list:draw(w, h, canUpdate)
end

function ViewConfig:scores(view)
	local w, h = Layout:move("scoreFilters")
	love.graphics.setFont(font.filterLine)
	love.graphics.setColor(Color.text)
	Theme:textWithShadow(view.scoreFilterLine, w, h, "center", "bottom")

	w, h = Layout:move("scores")

	local source = view.game.configModel.configs.select.scoreSourceName

	if source == "osu" then
		self.osuScoreListView:reloadItems()
	end

	local list = source == "osu" and self.osuScoreListView or self.scoreListView
	list:draw(w, h, canUpdate)

	if list.openResult then
		list.openResult = false
		view:result()
	end
end

local function difficulty(view, chartview)
	local w, h = Layout:move("difficulty")

	love.graphics.setColor(difficultyColor)
	love.graphics.setFont(font.difficulty)
	gfx_util.printBaseline(string.format("%0.02f", difficultyValue), 0, h / 2, w, 1, "center")

	love.graphics.setFont(font.calculator)
	gfx_util.printBaseline(calculator, 0, h / 1.2, w, 1, "center")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.patterns)
	w, h = Layout:move("patterns")
	gfx_util.printFrame(patterns:upper(), 0, 0, w, h, "center", "center")
end

local function info(view)
	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Color.innerPanel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local chartview = view.game.selectModel.chartview

	w, h = Layout:move("difficultyAndInfoLine")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setFont(font.info)

	if not chartview then
		return
	end

	difficulty(view, chartview)
	local length = time_util.format((chartview.duration or 0) / view.game.playContext.rate)
	local inputMode = Format.inputMode(chartview.chartdiff_inputmode)
	inputMode = inputMode == "2K" and "TAIKO" or inputMode

	local offset = 1.6

	w, h = Layout:move("info1row1")
	love.graphics.setFont(font.info)
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(string.format(Text.length, length), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info1row2")
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(string.format(Text.ln, longNoteRatio), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info1row3")
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(inputMode, 0, h / offset, w, 1, "center")
end

local function moreInfo(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	love.graphics.setFont(font.moreInfo)

	local bpm = (chartview.tempo or 0) * view.game.playContext.rate
	local noteCount = chartview.notes_count or 0
	local format = string.upper(chartview.format or "NONE")

	local offset = 1.6

	love.graphics.setColor(Color.text)
	local w, h = Layout:move("info2row1")
	gfx_util.printBaseline(string.format(Text.bpm, bpm), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info2row2")
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(string.format(Text.notes, noteCount), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info2row3")
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(format, 0, h / offset, w, 1, "center")
end

local function mods(view)
	local w, h = Layout:move("timeRate")

	love.graphics.setColor(Color.innerPanel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local delta = just.wheel_over("timeRate", just.is_over(w, h))
	if delta then
		view:changeTimeRate(delta)
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.timeRate)

	local rateType = view.game.configModel.configs.settings.gameplay.rate_type
	local timeRateModel = view.game.timeRateModel

	if rateType == "linear" then
		gfx_util.printBaseline(("%0.02f"):format(timeRateModel:get()), 0, h / 1.5, w, 1, "center")
	else
		gfx_util.printBaseline(("%iQ"):format(timeRateModel:get()), 0, h / 1.5, w, 1, "center")
	end

	w, h = Layout:move("modsAndInfoLine")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("mods")

	if just.is_over(w, h) then
		if just.mousepressed(1) then
			view:openModal("thetan.irizz.views.modals.ModifierModal")
		end
	end

	love.graphics.setFont(font.mods)
	love.graphics.setColor(Color.text)
	local modifiers = view.game.playContext.modifiers
	local modString = Theme:getModifierString(modifiers)

	if modString == "" then
		love.graphics.setFont(font.noMods)
		modString = Text.noMods
	end

	gfx_util.printFrame(modString, 0, -5, w, h, "center", "center")
end

local function footer(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	love.graphics.setFont(font.titleAndDifficulty)

	local left_text = string.format("%s - %s", chartview.artist, chartview.title)
	local right_text

	if not chartview.creator or chartview.creator == "" then
		right_text = string.format("[%s] %s", Format.inputMode(chartview.chartdiff_inputmode), chartview.name)
	else
		right_text = string.format(
			"[%s] [%s] %s",
			Format.inputMode(chartview.chartdiff_inputmode),
			chartview.creator or "",
			chartview.name
		)
	end

	local w, h = Layout:move("footerTitle")
	local left_scale = math_util.clamp(w / font.titleAndDifficulty:getWidth(left_text), 0, 1)
	w, h = Layout:move("footerChartName")
	local right_scale = math_util.clamp(w / font.titleAndDifficulty:getWidth(right_text), 0, 1)
	local scale = math.min(left_scale, right_scale)

	w, h = Layout:move("footerTitle")
	love.graphics.scale(scale, scale)
	love.graphics.translate(0, 5)
	Theme:textWithShadow(left_text, w / scale, h / scale, "left", "bottom")
	w, h = Layout:move("footerChartName")

	love.graphics.scale(scale, scale)
	love.graphics.translate(0, 5)
	Theme:textWithShadow(right_text, w / scale, h / scale, "right", "bottom")
	love.graphics.scale(1, 1)
end

function ViewConfig.layoutDraw(position)
	Layout:draw(position)
end

function ViewConfig.canDraw(position)
	return math.abs(position) < 1
end

function ViewConfig:draw(view, position)
	if not self.canDraw(position) then
		return
	end

	canUpdate = position == 0
	canUpdate = canUpdate and view:canUpdate()
	canUpdate = canUpdate and not actionModel.isInsertMode()

	self.panels()
	searchField(view)
	self:noteChartSets(view)
	self:noteChartList(view)
	self:scores(view)
	info(view)
	moreInfo(view)
	mods(view)
	footer(view)
	borders()
end

return ViewConfig
