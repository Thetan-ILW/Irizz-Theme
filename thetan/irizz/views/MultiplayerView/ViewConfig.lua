local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")
local time_util = require("time_util")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textMultiplayerScreen
local font = {}

local Format = require("sphere.views.Format")
local Layout = require("thetan.irizz.views.MultiplayerView.Layout")

local RoomUsersListView = require("thetan.irizz.views.MultiplayerView.RoomUsersListView")

local ViewConfig = class()

local boxes = {
	"playerList",
	"chartInfo",
	"buttons",
	"chat",
}

local gfx = love.graphics

function ViewConfig:new(game)
	font = Theme:getFonts("multiplayerView")
	self.roomUsersListView = RoomUsersListView(game)
end

function ViewConfig.panels()
	for _, name in ipairs(boxes) do
		local w, h = Layout:move(name)
		Theme:panel(w, h)
	end
end

function ViewConfig:footer(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	gfx.setFont(font.titleAndDifficulty)

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

	gfx.setColor(Color.text)
	local w, h = Layout:move("footerTitle")
	Theme:textWithShadow(leftText, w, h, "left", "top")
	w, h = Layout:move("footerChartName")
	Theme:textWithShadow(rightText, w, h, "right", "top")
end

local noUser = {}
local noUsers = {}

function ViewConfig:roomInfo(view)
	local room = view.game.multiplayerModel.room

	if not room then
		return
	end

	local users = room.users or noUsers

	local w, h = Layout:move("roomInfo")
	gfx.setFont(font.roomInfo)
	gyatt.frame(("Room: %s | %i players"):format(room.name, #users), 0, 0, w, h, "center", "top")
end

local function checkbox(id, v, label)
	local _, changed = imgui.checkbox(id, v, label)
	return changed
end

function ViewConfig:buttons(view)
	local w, h = Layout:move("buttons")

	Theme:panel(w, h)
	Theme:border(w, h)

	imgui.setSize(w, h, w / 2.5, Theme.imgui.size)

	local multiplayerModel = view.game.multiplayerModel
	local room = multiplayerModel.room
	local user = multiplayerModel.user or noUser

	if not room then
		return
	end

	local isHost = multiplayerModel:isHost()

	gfx.translate(15, 15)
	gfx.setFont(font.buttons)

	if checkbox("ready", user.isReady, "Ready") then
		multiplayerModel:switchReady()
	end

	if isHost then
		if checkbox("freeChart", room.is_free_notechart, "Free chart") then
			multiplayerModel:setFreeNotechart(not room.is_free_notechart)
		end
		if checkbox("freeMods", room.is_free_modifiers, "Free mods") then
			multiplayerModel:setFreeModifiers(not room.is_free_modifiers)
		end
		if checkbox("freeConst", room.is_free_const, "Free const") then
			multiplayerModel:setFreeConst(not room.is_free_const)
		end
		if checkbox("freeRate", room.is_free_rate, "Free rate") then
			multiplayerModel:setFreeRate(not room.is_free_rate)
		end
	else
		-- not a host
	end

	w, h = Layout:move("buttons")
	gfx.translate(15, h - 65)
	if imgui.button("mods", "Mods") then
		if room.is_free_modifiers or isHost then
			view.game.gameView:openModal("thetan.irizz.views.modals.ModifierModal")
		else
			view.game.gameView.showMessage("cantChangeMods")
		end
	end

	just.sameline()
	just.next(15)
	just.sameline()

	if isHost then
		if not room.isPlaying and imgui.button("Start match", "Start") then
			multiplayerModel:startMatch()
		elseif room.isPlaying and imgui.button("Stop match", "Stop") then
			multiplayerModel:stopMatch()
		end
	end
end

function ViewConfig:chartInfo(view)
	local chartview = view.game.selectModel.chartview
	local time_rate = view.game.playContext.rate

	if not chartview then
		return
	end

	local diff_column = view.game.configModel.configs.settings.select.diff_column
	local diff = (chartview.difficulty or 0)
	local diff_value = diff * time_rate
	local patterns = chartview.level and "Lv." .. chartview.level or Text.noPatterns

	if diff_column == "msd_diff" and chartview.msd_diff_data then
		local msd = Theme.getMsdFromData(chartview.msd_diff_data, time_rate)

		if msd then
			diff_value = msd.overall
			patterns = Theme.getMaxAndSecondFromMsd(msd) or Text.noPatterns
		end
	end

	local diff_color = Theme:getDifficultyColor(diff_value, diff_column)
	local calculator = Theme.formatDiffColumns(diff_column)

	local long_note_ratio = 0
	if chartview.notes_count and chartview.notes_count ~= 0 then
		long_note_ratio = ((chartview.long_notes_count or 0) / chartview.notes_count) * 100
	end

	local length = time_util.format((chartview.duration or 0) / view.game.playContext.rate)
	local input_mode = Format.inputMode(chartview.chartdiff_inputmode)
	input_mode = input_mode == "2K" and "TAIKO" or input_mode

	local w, h = Layout:move("chartInfo")

	Theme:panel(w, h)

	w, h = Layout:move("difficulty")
	gfx.setColor(Color.innerPanel)
	gfx.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("difficultyValue")
	gfx.rectangle("fill", 0, 0, w, h)

	gfx.setColor(diff_color)
	gfx.setFont(font.difficultyValue)
	gyatt.frame(("%0.02f"):format(diff_value), 0, -20, w, h, "center", "center")

	gfx.setFont(font.calculator)
	gyatt.frame(calculator, 0, 20, w, h, "center", "center")

	w, h = Layout:move("difficultyPatterns")
	gfx.setColor(Color.text)
	gfx.setFont(font.patterns)
	gyatt.frame(patterns, 0, 0, w, h, "center", "center")

	w, h = Layout:move("info")
	gfx.setColor(Color.text)
	gfx.setFont(font.info)
	gfx.translate(15, 0)
	gyatt.text(("Length: %s"):format(length), w)
	gyatt.text(("LN: %i%%"):format(long_note_ratio), w)
	gyatt.text(input_mode, w)

	w, h = Layout:move("chartInfo")
	Theme:border(w, h)
end

function ViewConfig:players(view)
	local w, h = Layout:move("playerList")

	Theme:panel(w, h)
	Theme:border(w, h)

	self.roomUsersListView:reloadItems()
	self.roomUsersListView:draw(w, h, true)
end

local chat = {
	message = "",
	index = 1,
}

function ViewConfig:chat(view)
	local w, h = Layout:move("chat")

	Theme:panel(w, h)
	Theme:border(w, h)
	local _p = 10

	gfx.setFont(font.chat)
	local lineHeight = font.chat:getHeight()

	gfx.translate(_p, _p)
	w = w - _p * 2
	h = h - _p * 2 - lineHeight

	just.clip(gfx.rectangle, "fill", 0, 0, w, h)

	local multiplayerModel = view.game.multiplayerModel
	local roomMessages = multiplayerModel.roomMessages

	local scroll = just.wheel_over(chat, just.is_over(w, h))

	chat.scroll = chat.scroll or 0
	gfx.translate(0, -chat.scroll)

	local startHeight = just.height

	for i = 1, #roomMessages do
		local message = roomMessages[i]
		just.text(message)
	end

	chat.height = just.height - startHeight
	just.clip()

	local content = chat.height
	local overlap = math.max(content - h, 0)
	if overlap > 0 then
		if scroll then
			chat.scroll = math.min(math.max(chat.scroll - scroll * 50, 0), overlap)
		elseif chat.messageCount ~= #roomMessages then
			chat.scroll = overlap
			chat.messageCount = #roomMessages
		end
	end

	w, h = Layout:move("chat")
	gfx.translate(_p, h - _p - lineHeight)
	w = w - _p * 2
	h = 50

	gfx.line(0, 0, w, 0)

	just.row(true)
	just.text(">")
	just.indent(10)

	local changed, left, right
	changed, chat.message, chat.index, left, right = just.textinput(chat.message, chat.index)
	just.text(left)
	gfx.line(0, 0, 0, lineHeight)
	just.text(right)
	just.row()

	if changed then
		chat.scroll = overlap
	end
	if just.keypressed("return") then
		multiplayerModel:sendMessage(chat.message)
		chat.message = ""
	end
end

function ViewConfig:draw(view)
	just.origin()
	self:roomInfo(view)
	self:players(view)
	self:chartInfo(view)
	self:buttons(view)
	self:chat(view)
	self:footer(view)
end

return ViewConfig
