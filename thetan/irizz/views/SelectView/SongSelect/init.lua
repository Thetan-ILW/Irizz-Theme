local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")
local time_util = require("time_util")
local math_util = require("math_util")

local TextInput = require("thetan.irizz.imgui.TextInput")

local Format = require("sphere.views.Format")
local Layout = require("thetan.irizz.views.SelectView.SongSelect.SongSelectLayout")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ui = require("thetan.irizz.ui")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

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

---@type skibidi.ActionModel
local actionModel

local gfx = love.graphics

local canUpdate = false

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ViewConfig:new(game, assets)
	actionModel = game.actionModel
	self.noteChartSetListView = NoteChartSetListView(game, assets)
	self.noteChartListView = NoteChartListView(game, assets)
	self.scoreListView = ScoreListView(game)
	self.osuScoreListView = OsuScoreListView(game)

	font = assets.localization.fontGroups.songSelect
	text = assets.localization.textGroups.songSelect
	ui:setColors(Theme.colors)
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
	patterns = chartview.level and "Lv." .. chartview.level or text.noPatterns

	if diffColumn == "msd_diff" and chartview.msd_diff_data then
		local msd = Theme.getMsdFromData(chartview.msd_diff_data, timeRate)

		if msd then
			difficultyValue = msd.overall
			patterns = Theme.getMaxAndSecondFromMsd(msd) or text.noPatterns
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
	gfx.setLineStyle("rough")
	gfx.setLineWidth(4)

	for i, name in pairs(boxes) do
		local w, h = Layout:move(name)
		Theme:border(w, h)
	end
end

local can_type = false

---@param view table
local function searchField(view)
	local vim_motions = actionModel.isVimMode()

	local config = view.game.configModel.configs.select

	gfx.setFont(font.searchField)

	local changed = false
	---@type string
	local search_text = config.filterString

	if not vim_motions or (actionModel.isInsertMode() and can_type) then
		changed, search_text = gyatt.textInput(config.filterString)
	end

	can_type = actionModel.isInsertMode() -- move textinput logic to actionModel

	local w, h = Layout:move("search")

	if search_text == "" then
		gfx.setColor(1, 1, 1, 0.5)
		gyatt.frame(text.searchPlaceholder, 0, 0, w, h - 40, "center", "center")
	else
		gfx.setColor(Color.text)
		gyatt.frame(search_text, 0, 0, w, h - 40, "center", "center")

		local font_w = font.searchField:getWidth(search_text)
		gfx.rectangle("fill", w / 2 - font_w / 2, h - 40, font_w, 4)
	end

	if actionModel.isEnabled() then
		if changed == "text" then
			view:updateSearch(search_text)
		end

		local delAll = actionModel.consumeAction("deleteLine")

		if delAll then
			view:updateSearch("")
		end
	end

	w, h = Layout:move("search")
	gfx.setFont(font.filterLine)
	gfx.setColor(Color.text)
	ui:frameWithShadow(view.chartFilterLine, 0, 0, w, h, "center", "bottom")

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

	gfx.setColor(difficultyColor)
	gfx.setFont(font.difficulty)
	gyatt.frame(("%0.02f"):format(difficultyValue), 0, 0, w, h, "center", "top")

	gfx.setFont(font.calculator)
	gyatt.frame(calculator, 0, -3, w, h, "center", "bottom")

	gfx.setColor(Color.text)
	gfx.setFont(font.patterns)
	w, h = Layout:move("patterns")
	gyatt.frame(patterns:upper(), 0, 0, w, h, "center", "center")
end

local function info(view)
	local w, h = Layout:move("difficulty")

	gfx.setColor(Color.innerPanel)
	gfx.rectangle("fill", 0, 0, w, h)

	local chartview = view.game.selectModel.chartview

	w, h = Layout:move("difficultyAndInfoLine")
	gfx.setColor(Color.separator)
	gfx.rectangle("fill", 0, 0, w, h)
	gfx.setFont(font.info)

	if not chartview then
		return
	end

	difficulty(view, chartview)
	local length = time_util.format((chartview.duration or 0) / view.game.playContext.rate)
	local mode = Format.inputMode(chartview.chartdiff_inputmode)
	mode = mode == "2K" and "TAIKO" or mode

	gfx.setFont(font.info)
	gfx.setColor(Color.text)

	w, h = Layout:move("info1row1")
	gyatt.text(text.length:format(length), w, "center")

	w, h = Layout:move("info1row2")
	gyatt.text(text.ln:format(longNoteRatio), w, "center")

	w, h = Layout:move("info1row3")
	gyatt.text(mode, w, "center")

	gfx.setColor(Color.separator)

	w, h = Layout:move("info1row1")
	gfx.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)

	w, h = Layout:move("info1row2")
	gfx.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
end

local function moreInfo(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	---@type number
	local bpm = (chartview.tempo or 0) * view.game.playContext.rate
	local note_count = chartview.notes_count or 0
	local format = string.upper(chartview.format or "NONE")

	gfx.setColor(Color.text)
	gfx.setFont(font.info)

	local w, h = Layout:move("info2row1")
	gyatt.text(text.bpm:format(bpm), w, "center")

	w, h = Layout:move("info2row2")
	gyatt.text(text.noteCount:format(note_count), w, "center")

	w, h = Layout:move("info2row3")
	gyatt.text(format, w, "center")

	gfx.setColor(Color.separator)
	w, h = Layout:move("info2row1")
	gfx.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
	w, h = Layout:move("info2row2")
	gfx.rectangle("fill", w / 2 - w / 4, h - 5, w / 2, 4)
end

local function mods(view)
	local w, h = Layout:move("timeRate")

	gfx.setColor(Color.innerPanel)
	gfx.rectangle("fill", 0, 0, w, h)

	local delta = just.wheel_over("timeRate", just.is_over(w, h))

	if delta then
		view:changeTimeRate(delta)
	end

	gfx.setColor(Color.text)
	gfx.setFont(font.timeRate)

	---@type "linear" | "exp"
	local rate_type = view.game.configModel.configs.settings.gameplay.rate_type
	---@type sphere.TimeRateModel
	local time_rate_model = view.game.timeRateModel

	if rate_type == "linear" then
		gyatt.frame(("%0.02f"):format(time_rate_model:get()), 0, 0, w, h, "center", "center")
	else
		gyatt.frame(("%iQ"):format(time_rate_model:get()), 0, 0, w, h, "center", "center")
	end

	w, h = Layout:move("modsAndInfoLine")
	gfx.setColor(Color.separator)
	gfx.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("mods")

	if just.is_over(w, h) then
		if just.mousepressed(1) then
			view:openModal("thetan.irizz.views.modals.ModifierModal")
		end
	end

	gfx.setFont(font.mods)
	gfx.setColor(Color.text)
	local modifiers = view.game.playContext.modifiers
	local modString = Theme:getModifierString(modifiers)

	if modString == "" then
		love.graphics.setFont(font.noMods)
		modString = text.noMods
	end

	gyatt.frame(modString, 0, -5, w, h, "center", "center")
end

local function footer(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	gfx.setFont(font.titleAndDifficulty)

	local left_text = ("%s - %s"):format(chartview.artist, chartview.title)
	local right_text ---@type string

	if not chartview.creator or chartview.creator == "" then
		right_text = ("[%s] %s"):format(Format.inputMode(chartview.chartdiff_inputmode), chartview.name)
	else
		right_text = ("[%s] [%s] %s"):format(
			Format.inputMode(chartview.chartdiff_inputmode),
			chartview.creator or "",
			chartview.name
		)
	end

	local w, h = Layout:move("footerTitle")
	local left_scale = math_util.clamp(w / (font.titleAndDifficulty:getWidth(left_text) * gyatt.getTextScale()), 0, 1)
	w, h = Layout:move("footerChartName")
	local right_scale = math_util.clamp(w / (font.titleAndDifficulty:getWidth(right_text) * gyatt.getTextScale()), 0, 1)
	local scale = math.min(left_scale, right_scale)

	w, h = Layout:move("footerTitle")
	gyatt.scale(scale)
	gfx.translate(0, 5)
	ui:frameWithShadow(left_text, 0, 0, w, h, "left", "bottom")

	w, h = Layout:move("footerChartName")
	gyatt.scale(scale)
	gfx.translate(0, 5)
	ui:frameWithShadow(right_text, 0, 0, w, h, "right", "bottom")

	gyatt.scale(1)
end

function ViewConfig:chartPreview(view, position)
	local prevCanvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas("chartPreview")

	gfx.setCanvas(canvas)
	gfx.clear()
	view.chartPreviewView:draw()
	gfx.setCanvas({ prevCanvas, stencil = true })

	local width, _ = gfx.getDimensions()
	gfx.origin()
	gfx.translate(width * position, 0)
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(canvas)
end

function ViewConfig.layoutDraw(position, songSelectOffset)
	Layout:draw(position, songSelectOffset)
end

function ViewConfig:canDraw(position)
	return math.abs(position) < 0.99
end

function ViewConfig:draw(view, position)
	if not self:canDraw(position) then
		return
	end

	canUpdate = position == 0
	canUpdate = canUpdate and view:canUpdate()
	canUpdate = canUpdate and not actionModel.isInsertMode()

	self:chartPreview(view, position)
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
