local class = require("class")
local just = require("just")
local gfx_util = require("gfx_util")
local time_util = require("time_util")
local flux = require("flux")
local TextInput = require("thetan.iris.imgui.TextInput")
local ScrollBar = require("thetan.iris.imgui.ScrollBar")

local Format = require("sphere.views.Format")
local Layout = require("thetan.iris.views.SelectView.SongSelect.SongSelectLayout")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textSongSelect
local font

local NoteChartSetListView = require("thetan.iris.views.SelectView.SongSelect.NoteChartSetListView")
local NoteChartListView = require("thetan.iris.views.SelectView.SongSelect.NoteChartListView")
local ScoreListView = require("thetan.iris.views.ScoreListView")

local boxes = {
	"scores",
	"infoAndMods",
	"column2",
	"difficultyAndInfo",
	"charts",
}

local ViewConfig = class()

local canUpdate = false

function ViewConfig:new(game)
	self.noteChartSetListView = NoteChartSetListView(game)
	self.noteChartListView = NoteChartListView(game)
	self.scoreListView = ScoreListView(game)
	font = Theme:getFonts("songSelectViewConfig")
end

local function panels(view)
	for _, name in pairs(boxes) do
		local w, h = Layout:move(name)
		Theme:panel(w, h)
	end
end

local function borders(view)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)

	for i, name in pairs(boxes) do
		local w, h = Layout:move(name)
		Theme:border(w, h)
	end
end

---@param view table
local function searchField(view)
	if not just.focused_id then
		just.focus("SearchField")
	end

	local w, h = Layout:move("search")

	local delAll = love.keyboard.isDown("lctrl") and love.keyboard.isDown("backspace")

	local config = view.game.configModel.configs.select
	local selectModel = view.game.selectModel

	love.graphics.setFont(font.searchField)
	local changed, text = TextInput("SearchField", { config.filterString, Text.searchPlaceholder }, nil, w, h)

	if changed == "text" then
		if delAll then
			text = ""
		end
		config.filterString = text
		selectModel:debouncePullNoteChartSet()
	end
end

function ViewConfig:noteChartSets(view)
	local w, h = Layout:move("column2")

	local list = self.noteChartSetListView
	list:draw(w, h, canUpdate)

	local count = #list.items - 1

	love.graphics.translate(w - 16, 0)

	local pos = (list.visualItemIndex - 1) / count
	local newScroll = ScrollBar("ncs_sb", pos, 16, h, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end

---@param view table
function ViewConfig:noteChartList(view)
	local w, h = Layout:move("charts")

	local list = self.noteChartListView
	list:draw(w, h, canUpdate)
end

function ViewConfig:scores(view)
	local w, h = Layout:move("scores")

	local list = self.scoreListView
	list:draw(w, h, canUpdate)

	if list.openResult then
		list.openResult = false
		view:result()
	end
end

---@param view table
---@param noteChartItem table
local function enpsDifficulty(view, noteChartItem)
	if not noteChartItem.difficulty then
		return
	end

	local baseTimeRate = view.game.playContext.rate

	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Theme:getDifficultyColor(noteChartItem.difficulty * baseTimeRate, "enps"))
	love.graphics.setFont(font.difficulty)
	gfx_util.printBaseline(string.format("%0.02f", noteChartItem.difficulty * baseTimeRate), 0, h / 2, w, 1, "center")

	love.graphics.setFont(font.calculator)
	gfx_util.printBaseline("ENPS", 0, h / 1.2, w, 1, "center")
end

---@param view table
---@param noteChartItem table
local function msdDifficulty(view, noteChartItem)
	if not noteChartItem.difficulty then
		return
	end

	local baseTimeRate = view.game.playContext.rate
	
	local rate = 1.0
	if math.abs(baseTimeRate - 1) > 0.00001 then
		rate = baseTimeRate / 1.04
	end
	
	local difficultyData = noteChartItem.difficulty_data or nil
	local patterns = ""

	for key, value in pairs(difficultyData) do
		patterns = string.format("%s%0.02f %s\n", patterns, value * rate, key)
	end

	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Theme:getDifficultyColor(noteChartItem.difficulty * baseTimeRate, "msd"))
	love.graphics.setFont(font.difficulty)
	gfx_util.printBaseline(string.format("%0.02f", noteChartItem.difficulty * baseTimeRate), 0, h / 2, w, 1, "center")

	love.graphics.setFont(font.calculator)
	gfx_util.printBaseline("DUPS", 0, h / 1.2, w, 1, "center")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.patterns)
	w, h = Layout:move("patterns")
	gfx_util.printFrame(patterns, -3, 15, w, h, "center", "center")
end

local function difficulty(view, chartview)
	local difficulty = chartview.difficulty 

	if not difficulty then
		difficulty = 0
	end

	local diffColumn = view.game.configModel.configs.settings.select.diff_column
	local baseTimeRate = view.game.playContext.rate

	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Theme:getDifficultyColor(difficulty * baseTimeRate, diffColumn))
	love.graphics.setFont(font.difficulty)
	gfx_util.printBaseline(string.format("%0.02f", difficulty * baseTimeRate), 0, h / 2, w, 1, "center")

	love.graphics.setFont(font.calculator)
	local calculator = Theme.formatDiffColumns(diffColumn)
	gfx_util.printBaseline(calculator, 0, h / 1.2, w, 1, "center")

	local patterns = chartview.msd_diff_data or Text.noPatterns
	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.patterns)
	w, h = Layout:move("patterns")
	gfx_util.printFrame(patterns, 0, 0, w, h, "center", "center")
end

local function info(view)
	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Color.transparentPanel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local chartview = view.game.selectModel.chartview

	w, h = Layout:move("difficultyAndInfoLine")
	love.graphics.setColor(Color.mutedBorder)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setFont(font.info)

	if not chartview then
		return
	end

	difficulty(view, chartview)
	local length = time_util.format((chartview.duration or 0) / view.game.playContext.rate)
	local longNoteRatio = (chartview.long_note_count or 0) / chartview.notes_count
	local inputMode = Format.inputMode(chartview.chartdiff_inputmode)
	inputMode = inputMode == "2K" and "TAIKO" or inputMode

	local offset = 1.6

	w, h = Layout:move("info1row1")
	love.graphics.setFont(font.info)
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(string.format(Text.length, length), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.mutedBorder)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info1row2")
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(string.format(Text.ln, longNoteRatio), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.mutedBorder)
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
	local format = string.upper(chartview.format) or "None"

	local offset = 1.6

	love.graphics.setColor(Color.text)
	local w, h = Layout:move("info2row1")
	gfx_util.printBaseline(string.format(Text.bpm, bpm), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.mutedBorder)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info2row2")
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(string.format(Text.notes, noteCount), 0, h / offset, w, 1, "center")
	love.graphics.setColor(Color.mutedBorder)
	love.graphics.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info2row3")
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(format, 0, h / offset, w, 1, "center")
end

local function mods(view)
	local w, h = Layout:move("timeRate")

	love.graphics.setColor(Color.transparentPanel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local delta = just.wheel_over("timeRate", just.is_over(w, h))
	if delta and not view.modalActive then
		local newRate = view.game.playContext.rate + 0.05 * delta
		local timeRateModel = view.game.timeRateModel

		if newRate ~= timeRateModel:get() then
			view.game.modifierSelectModel:change()
			timeRateModel:set(newRate)
		end
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.timeRate)

	local baseTimeRate = view.game.playContext.rate
	gfx_util.printBaseline(string.format("%0.02f", baseTimeRate), 0, h / 1.5, w, 1, "center")

	w, h = Layout:move("modsAndInfoLine")
	love.graphics.setColor(Color.mutedBorder)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("mods")

	if just.is_over(w, h) then
		if just.mousepressed(1) then
			view:openModal("thetan.iris.views.modals.ModifierModal")
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

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.titleAndDifficulty)

	local w, h = Layout:move("footerTitle")
	just.text(string.format("%s - %s", chartview.artist, chartview.title), w)
	just.text(string.format("%s - %s", chartview.artist, chartview.title), w)
	w, h = Layout:move("footerChartName")
	just.text(
		string.format(
			"[%s] [%s] %s",
			Format.inputMode(chartview.chartdiff_inputmode),
			chartview.creator or "",
			chartview.name
		),
		w,
		true
	)
end

function ViewConfig:draw(view, position)
	Layout:draw(position)

	canUpdate = position == 0
	canUpdate = canUpdate and not view.modalActive

	if math.abs(position) >= 1 then
		return
	end

	panels(view)
	searchField(view)
	self:noteChartSets(view)
	self:noteChartList(view)
	self:scores(view)
	info(view)
	moreInfo(view)
	mods(view)
	footer(view)
	borders(view)
end

return ViewConfig
