local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")
local gfx_util = require("gfx_util")
local time_util = require("time_util")

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
		difficultyValue = Theme.getApproximate(diff, chartview.msd_diff_data, timeRate)
		patterns = Theme.getMaxAndSecondFromSsr(chartview.msd_diff_data) or Text.noPatterns
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
	gfx_util.printFrame(patterns, 0, 0, w, h, "center", "center")
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

	local baseTimeRate = view.game.playContext.rate
	gfx_util.printBaseline(Format.timeRate(baseTimeRate), 0, h / 1.5, w, 1, "center")

	w, h = Layout:move("modsAndInfoLine")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("mods")

	if just.is_over(w, h) then
		if just.mousepressed(1) then
			view:openModal("thetan.irizz.views.modals.ModifierModal")
		end
	end

	local mods = view.game.playContext.modifiers

	love.graphics.setFont(font.mods)
	love.graphics.setColor(Color.text)
	gfx_util.printFrame(Theme:getModifierString(mods), 0, -5, w, h, "center", "center")
end

local function footer(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	love.graphics.setFont(font.titleAndDifficulty)

	local leftText = string.format("%s - %s", chartview.artist, chartview.title)
	local rightText

	if not chartview.creator or chartview.creator == "" then
		rightText = string.format("[%s] %s", Format.inputMode(chartview.chartdiff_inputmode), chartview.name)
	else
		rightText = string.format(
			"[%s] [%s] %s",
			Format.inputMode(chartview.chartdiff_inputmode),
			chartview.creator or "",
			chartview.name
		)
	end

	local w, h = Layout:move("footerTitle")
	Theme:textWithShadow(leftText, w, h, "left", "top")
	w, h = Layout:move("footerChartName")
	Theme:textWithShadow(rightText, w, h, "right", "top")
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
