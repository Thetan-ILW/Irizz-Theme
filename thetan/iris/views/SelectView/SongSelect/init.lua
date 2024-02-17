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

local ModifierEncoder = require("sphere.models.ModifierEncoder")
local ModifierModel = require("sphere.models.ModifierModel")

local NoteChartSetListView = require("thetan.iris.views.SelectView.SongSelect.NoteChartSetListView")
local NoteChartListView = require("thetan.iris.views.SelectView.SongSelect.NoteChartListView")
local ScoreListView = require("thetan.iris.views.SelectView.SongSelect.ScoreListView")

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

local function Frames(view)
	for i, name in pairs(boxes) do
		local w, h = Layout:move(name)
		love.graphics.setColor(Color.panel)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
end

local function Borders(view)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)

	for i, name in pairs(boxes) do
		local w, h = Layout:move(name)
		love.graphics.setColor(Color.border)
		love.graphics.rectangle("line", -2, -2, w + 3, h + 3)
	end
end

---@param view table
local function SearchField(view)
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

function ViewConfig:NoteChartSets(view)
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
function ViewConfig:NoteChartList(view)
	local w, h = Layout:move("charts")

	local list = self.noteChartListView
	list:draw(w, h, canUpdate)
end

function ViewConfig:Scores(view)
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
local function EnpsDifficulty(view, noteChartItem)
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
local function MsdDifficulty(view, noteChartItem)
	if not noteChartItem.difficulty then
		return
	end

	local baseTimeRate = view.game.playContext.rate

	if baseTimeRate ~= 1 then
		baseTimeRate = baseTimeRate / 1.04
	end

	local difficultyData = noteChartItem.difficulty_data or "None"
	difficultyData = difficultyData:gsub(";", "\n")

	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Theme:getDifficultyColor(noteChartItem.difficulty * baseTimeRate, "msd"))
	love.graphics.setFont(font.difficulty)
	gfx_util.printBaseline(string.format("%0.02f", noteChartItem.difficulty * baseTimeRate), 0, h / 2, w, 1, "center")

	love.graphics.setFont(font.calculator)
	gfx_util.printBaseline("MSD", 0, h / 1.2, w, 1, "center")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.patterns)
	w, h = Layout:move("patterns")
	just.indent(-5)
	just.text(difficultyData, w, true)
end

local function Info(view)
	local w, h = Layout:move("difficulty")

	love.graphics.setColor(Color.transparentPanel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("difficultyAndInfoLine")
	love.graphics.setColor(Color.mutedBorder)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local noteChartItem = view.game.selectModel.noteChartItem

	if not noteChartItem then
		return
	end

	if noteChartItem.difficulty_data then
		MsdDifficulty(view, noteChartItem)
	else
		EnpsDifficulty(view, noteChartItem)
	end

	love.graphics.setFont(font.info)

	local length = time_util.format((noteChartItem.length or 0) / view.game.playContext.rate)
	local longNoteRatio = noteChartItem.longNoteRatio or 0
	local inputMode = Format.inputMode(noteChartItem.inputMode)
	inputMode = inputMode == "2K" and "TAIKO" or inputMode

	local offset = 1.6

	w, h = Layout:move("info1row1")
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

local function MoreInfoLol(view)
	local noteChartItem = view.game.selectModel.noteChartItem

	if not noteChartItem then
		return
	end

	love.graphics.setFont(font.moreInfo)

	local bpm = (noteChartItem.bpm or 0) * view.game.playContext.rate
	local noteCount = noteChartItem.noteCount or 0
	local format = string.upper(noteChartItem.format) or "None"

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

---@param mods table
---@return string
local function GetModifierString(mods)
	if type(mods) == "string" then
		mods = ModifierEncoder:decode(mods)
	end

	local modString = ""
	for _, mod in pairs(mods) do
		local modifier = ModifierModel:getModifier(mod.id)

		if modifier then
			local modifierString, modifierSubString = modifier:getString(mod)
			modString = string.format("%s %s%s", modString, modifierString, modifierSubString or "")
		end
	end

	return modString
end

local function Mods(view)
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

	just.text(GetModifierString(mods), w)
end

local function Footer(view)
	local noteChartItem = view.game.selectModel.noteChartItem

	if not noteChartItem then
		return
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.titleAndDifficulty)

	local w, h = Layout:move("footerTitle")
	just.text(string.format("%s - %s", noteChartItem.artist, noteChartItem.title), w)

	w, h = Layout:move("footerChartName")
	just.text(
		string.format(
			"[%s] [%s] %s",
			Format.inputMode(noteChartItem.inputMode),
			noteChartItem.creator,
			noteChartItem.name
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

	Frames(view)
	SearchField(view)
	self:NoteChartSets(view)
	self:NoteChartList(view)
	self:Scores(view)
	Info(view)
	MoreInfoLol(view)
	Mods(view)
	Footer(view)
	Borders(view)
end

return ViewConfig
