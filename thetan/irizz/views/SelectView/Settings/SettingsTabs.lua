local class = require("class")

local just = require("just")
local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")
local table_util = require("table_util")
local Container = require("thetan.gyatt.Container")
local audio = require("audio")
local version = require("version")

local ui = require("thetan.irizz.ui")
local Theme = require("thetan.irizz.views.Theme")

---@type table<string, string>
local text
local cfg = Theme.imgui

local InputListView = require("thetan.irizz.views.modals.InputModal.InputListView")

local SettingsTab = class()

---@type string[]
local start_sound_names
---@type string[]
local osu_skins
---@type string[]
local color_themes

local textSeparation = 15
local panelW = 0
local panelH = 0
local inputListView

SettingsTab.container = Container("settingsContainer")

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function SettingsTab:new(game, assets)
	text = assets.localization.textGroups.settings
	start_sound_names = assets.startSoundNames
	osu_skins = game.assetModel:getOsuSkins()
	color_themes = assets.colorThemes

	self.assets = assets

	inputListView = InputListView(game, assets)
end

function SettingsTab:updateItems(view)
	inputListView.inputMode = tostring(view.game.selectController.state.inputMode)
	inputListView:reloadItems()
end

function SettingsTab:reset()
	self.container:reset()
end

function SettingsTab:draw(view, w, h, tab)
	imgui.setSize(w, h, w / 2.5, cfg.size)
	panelW = w
	panelH = h

	local startHeight = just.height
	self.container:startDraw(w, h)

	ui:setLines()
	self[tab](self, view)

	self.container.scrollLimit = just.height - startHeight - h
	self.container.stopDraw()
end

---@param id any
---@param v number
---@param label string
---@return number
local function intButtonsMs(id, v, label)
	return imgui.intButtons(id, v * 1000, 1, label) / 1000
end

---@param v number?
---@return string
local function formatActionOnFail(v)
	return text[v] or ""
end

---@param v number?
---@return string
local function formatSpeedType(v)
	return text[v] or ""
end

---@param v number?
---@return string
local function formatTempoFactor(v)
	return text[v] or ""
end

local function formatNoteSkin(v)
	if not v.name then
		return "??"
	end

	local len = v.name:len()

	if len > 20 then
		return v.name:sub(1, 20) .. "..."
	end

	return v.name
end

function SettingsTab:Gameplay(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.gameplay

	local speedModel = view.game.speedModel
	local speedRange = speedModel.range[g.speedType]
	local speedFormat = speedModel.format[g.speedType]

	gyatt.text(text.scrollSpeed)
	just.next(0, textSeparation)

	local newSpeed = imgui.slider1(
		"speed",
		speedModel:get(),
		speedFormat,
		speedRange[1],
		speedRange[2],
		speedRange[3],
		text.scrollSpeed
	)
	speedModel:set(newSpeed)

	g.speedType = imgui.combo("speedType", g.speedType, speedModel.types, formatSpeedType, text.speedType)

	g.longNoteShortening = imgui.slider1(
		"shortening",
		g.longNoteShortening * 1000,
		"%dms",
		-300,
		0,
		10,
		text.lnShortening
	) / 1000

	g.tempoFactor = imgui.combo(
		"tempoFactor",
		g.tempoFactor,
		{ "average", "primary", "minimum", "maximum" },
		formatTempoFactor,
		text.tempoFactor
	)
	if g.tempoFactor == "primary" then
		g.primaryTempo = imgui.slider1("primaryTempo", g.primaryTempo, text.bpm, 60, 240, 1, text.primaryTempo)
	end

	g.swapVelocityType = imgui.checkbox("swapVelocityType", g.swapVelocityType, text.taikoSV)

	if not g.swapVelocityType then
		g.scaleSpeed = imgui.checkbox("scaleSpeed", g.scaleSpeed, text.scaleScrollSpeed)
	end
	g.eventBasedRender = g.swapVelocityType
	g.scaleSpeed = g.swapVelocityType and true or g.scaleSpeed
	local playContext = view.game.playContext
	playContext.const = imgui.checkbox("const", playContext.const, text.const)

	imgui.separator()
	gyatt.text(text.waitTime)
	just.next(0, textSeparation)
	g.time.prepare = imgui.slider1("time.prepare", g.time.prepare, "%0.1f", 0.5, 3, 0.1, text.prepare)
	g.time.playPause = imgui.slider1("time.playPause", g.time.playPause, "%0.1f", 0, 2, 0.1, text.playPause)
	g.time.playRetry = imgui.slider1("time.playRetry", g.time.playRetry, "%0.1f", 0, 2, 0.1, text.playRetry)
	g.time.pausePlay = imgui.slider1("time.pausePlay", g.time.pausePlay, "%0.1f", 0, 2, 0.1, text.pausePlay)
	g.time.pauseRetry = imgui.slider1("time.pauseRetry", g.time.pauseRetry, "%0.1f", 0, 2, 0.1, text.pauseRetry)

	local input_mode = tostring(view.game.selectController.state.inputMode)

	if input_mode ~= "" then
		imgui.separator()
		gyatt.text(text.noteSkin)
		just.next(0, textSeparation)

		local selected_note_skin = view.game.noteSkinModel:getNoteSkin(input_mode)
		local skins = view.game.noteSkinModel:getSkinInfos(input_mode)
		local select, changed = imgui.combo("sphere.skinSelect", selected_note_skin, skins, formatNoteSkin, "")

		if changed then
			view.game.noteSkinModel:setDefaultNoteSkin(input_mode, select:getPath())
		end

		just.sameline()
		local pressed = imgui.button("skinSettings", "Settings")

		if pressed then
			view.game.gameView:openModal("thetan.irizz.views.modals.NoteSkinModal")
		end
	end
end

local soundsphere = require("sphere.models.RhythmModel.ScoreEngine.SoundsphereScoring")
local osuMania = require("sphere.models.RhythmModel.ScoreEngine.OsuManiaScoring")
local osuLegacy = require("sphere.models.RhythmModel.ScoreEngine.OsuLegacyScoring")
local quaver = require("sphere.models.RhythmModel.ScoreEngine.QuaverScoring")
local etterna = require("sphere.models.RhythmModel.ScoreEngine.EtternaScoring")
local lr2 = require("sphere.models.RhythmModel.ScoreEngine.LunaticRaveScoring")

local timings = require("sphere.models.RhythmModel.ScoreEngine.timings")

local scoreSystems = {
	"soundsphere",
	"osu!mania",
	"osu!legacy",
	"Quaver",
	"Etterna",
	"Lunatic rave 2",
}

local metadata = {
	["soundsphere"] = soundsphere.metadata,
	["osu!mania"] = osuMania.metadata,
	["osu!legacy"] = osuLegacy.metadata,
	["Quaver"] = quaver.metadata,
	["Etterna"] = etterna.metadata,
	["Lunatic rave 2"] = lr2.metadata,
}

local function getJudges(range)
	local t = {}

	for i = range[1], range[2], 1 do
		table.insert(t, i)
	end

	return t
end

local allJudges = {
	["osu!mania"] = getJudges(osuMania.metadata.range),
	["osu!legacy"] = getJudges(osuLegacy.metadata.range),
	["Etterna"] = getJudges(etterna.metadata.range),
	["Lunatic rave 2"] = getJudges(lr2.metadata.range),
}

local lunaticRaveJudges = {
	[0] = "Easy",
	[1] = "Normal",
	[2] = "Hard",
	[3] = "Very hard",
}

local function formatLunaticRave(j)
	return lunaticRaveJudges[j]
end

-- Worst function I have ever wrote.
local function scoreSystem(updated, selectedScoreSystem, irizz, select, playContext)
	local judges = allJudges[selectedScoreSystem]

	if judges then
		if updated then
			irizz.judge = judges[1]
		end

		local prevJudge = irizz.judge

		if irizz.scoreSystem == "Lunatic rave 2" then
			irizz.judge = imgui.combo("irizz.judge", irizz.judge, judges, formatLunaticRave, text.judgement)
		else
			irizz.judge = imgui.combo("irizz.judge", irizz.judge, judges, nil, text.judgement)
		end

		local alias = metadata[selectedScoreSystem].rangeValueAlias
		local judge = irizz.judge

		if alias then
			judge = alias[judge]
		end

		select.judgements = metadata[irizz.scoreSystem].name:format(judge)

		if prevJudge ~= irizz.judge then
			updated = true
		end
	else
		local md = metadata[irizz.scoreSystem]

		if not md then
			md = metadata["soundsphere"]
		end

		select.judgements = md.name
	end

	if not updated then
		return
	end

	local ss = irizz.scoreSystem

	if ss == "soundsphere" then
		playContext.timings = table_util.deepcopy(timings.soundsphere)
	elseif ss == "osu!mania" then
		playContext.timings = table_util.deepcopy(timings.osuMania(irizz.judge))
	elseif ss == "osu!legacy" then
		playContext.timings = table_util.deepcopy(timings.osuLegacy(irizz.judge))
	elseif ss == "Etterna" then
		playContext.timings = table_util.deepcopy(timings.etterna)
	elseif ss == "Quaver" then
		playContext.timings = table_util.deepcopy(timings.quaver)
	elseif ss == "Lunatic rave 2" then
		playContext.timings = table_util.deepcopy(timings.lr2)
	end
end

local function noteTiming(value, minimum, positive, label)
	value = math.abs(value * 1000)
	value = imgui.intButtons(label, value, 1, label)
	value = math.max(value / 1000, math.abs(minimum))

	if not positive then
		value = -value
	end

	return value
end

local function noteTimingGroup(note, hitLabel, missLabel)
	note.hit[1] = noteTiming(note.hit[1], 0, false, hitLabel .. text.early)
	note.miss[1] = noteTiming(note.miss[1], note.hit[1], false, missLabel .. text.early)
	note.hit[2] = noteTiming(note.hit[2], 0, true, hitLabel .. text.late)
	note.miss[2] = noteTiming(note.miss[2], note.hit[2], true, missLabel .. text.late)
end

function SettingsTab:Scoring(view)
	local configs = view.game.configModel.configs
	local select = configs.select
	local irizz = configs.irizz
	local settings = configs.settings
	local g = settings.gameplay

	imgui.separator()
	gyatt.text(text.scoring)
	just.next(0, textSeparation)

	local prevScoreSystem = irizz.scoreSystem
	irizz.scoreSystem = imgui.combo("irizz.scoreSystem", irizz.scoreSystem, scoreSystems, nil, text.scoreSystem)

	scoreSystem(prevScoreSystem ~= irizz.scoreSystem, irizz.scoreSystem, irizz, select, view.game.playContext)
	local noteTimings = view.game.playContext.timings
	noteTimings.nearest = imgui.checkbox("timings.nearest", noteTimings.nearest, text.nearest)

	local note = noteTimings.ShortNote
	local ln = noteTimings.LongNoteStart
	local release = noteTimings.LongNoteEnd

	imgui.separator()
	noteTimingGroup(note, text.noteHitWindow, text.noteMissWindow)
	imgui.separator()
	noteTimingGroup(ln, text.lnHitWindow, text.lnMissWindow)
	imgui.separator()
	noteTimingGroup(release, text.releaseHitWindow, text.releaseMissWindow)

	imgui.separator()
	gyatt.text(text.hp)
	just.next(0, textSeparation)
	g.hp.shift = imgui.checkbox("hp.shift", g.hp.shift, text.hpShift)
	g.hp.notes = math.min(math.max(imgui.intButtons("hp.notes", g.hp.notes, 1, text.hpNotes), 0), 100)
	g.actionOnFail =
		imgui.combo("actionOnFail", g.actionOnFail, { "none", "pause", "quit" }, formatActionOnFail, text.actionOnFail)

	imgui.separator()
	gyatt.text(text.other)
	just.next(0, textSeparation)
	g.ratingHitTimingWindow = intButtonsMs("ratingHitTimingWindow", g.ratingHitTimingWindow, text.ratingHitWindow)
	g.lastMeanValues = imgui.intButtons("lastMeanValues", g.lastMeanValues, 1, text.lastMeanValues)
end

local formats = { "osu", "qua", "sm", "ksh" }
local audio_modes = { "bass_sample", "bass_fx_tempo" }

local _formatModes = {
	bass_sample = "BASS sample",
	bass_fx_tempo = "BASS FX tempo",
}

---@param mode string
---@return string
local function formatModes(mode)
	return _formatModes[mode] or mode
end

function SettingsTab:Timings(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.gameplay
	local of = g.offset_format
	local oam = g.offset_audio_mode

	gyatt.text(text.timingsTab)
	just.next(0, textSeparation)

	g.offset.input = intButtonsMs("input offset", g.offset.input, text.inputOffest)
	g.offset.visual = intButtonsMs("visual offset", g.offset.visual, text.visualOffset)
	g.offsetScale.input = imgui.checkbox("offsetScale.input", g.offsetScale.input, text.multiplyInputOffset)
	g.offsetScale.visual = imgui.checkbox("offsetScale.visual", g.offsetScale.visual, text.multiplyVisualOffset)

	imgui.separator()
	gyatt.text(text.chartFormatOffsets)
	just.next(0, textSeparation)

	for _, format in ipairs(formats) do
		of[format] = intButtonsMs("offset " .. format, of[format], format)
	end

	imgui.separator()
	gyatt.text(text.audioModeOffsets)
	just.next(0, textSeparation)

	for _, audio_mode in ipairs(audio_modes) do
		oam[audio_mode] = intButtonsMs("offset " .. audio_mode, oam[audio_mode], formatModes(audio_mode))
	end
end

---@param mode string
---@return string
local function formatVolumeType(mode)
	return text[mode] or ""
end

function SettingsTab:Audio(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local irizz = configs.irizz
	local a = settings.audio
	local g = settings.gameplay

	gyatt.text(text.volume)
	just.next(0, textSeparation)

	a.volumeType =
		imgui.combo("a.volumeType", a.volumeType, { "linear", "logarithmic" }, formatVolumeType, text.volumeType)

	local v = a.volume

	local oldMaster = v.master
	local oldUi = irizz.uiVolume

	if a.volumeType == "linear" then
		v.master = imgui.slider1("v.master", v.master * 100, "%i%%", 0, 100, 1, text.master) / 100
		v.music = imgui.slider1("v.music", v.music * 100, "%i%%", 0, 100, 1, text.music) / 100
		v.effects = imgui.slider1("v.effects", v.effects * 100, "%i%%", 0, 100, 1, text.effects) / 100
		v.metronome = imgui.slider1("v.metronome", v.metronome * 100, "%i%%", 0, 100, 1, text.metronome) / 100
		irizz.uiVolume = imgui.slider1("irizz.uiVolume", irizz.uiVolume * 100, "%i%%", 0, 100, 1, text.uiVolume) / 100
	elseif a.volumeType == "logarithmic" then
		v.master = imgui.lfslider("v.master", v.master, "%ddB", -60, 0, 1, text.master)
		v.music = imgui.lfslider("v.music", v.music, "%ddB", -60, 0, 1, text.music)
		v.effects = imgui.lfslider("v.effects", v.effects, "%ddB", -60, 0, 1, text.effects)
		v.metronome = imgui.lfslider("v.metronome", v.metronome, "%ddB", -60, 0, 1, text.metronome)
		irizz.uiVolume = imgui.lfslider("irizz.uiVolume", irizz.uiVolume, "%ddB", -60, 0, 1, text.uiVolume)
	end

	if v.master ~= oldMaster or irizz.uiVolume ~= oldUi then
		view.assets:updateVolume(view.game.configModel)
	end

	local mode = a.mode

	local pitch = mode.primary == "bass_sample" and true or false
	pitch = imgui.checkbox("audioPitch", pitch, text.audioPitch)

	local audioMode = pitch and "bass_sample" or "bass_fx_tempo"

	mode.primary = audioMode
	mode.secondary = audioMode

	g.autoKeySound = imgui.checkbox("autoKeySound", g.autoKeySound, text.autoKeySound)
	a.midi.constantVolume = imgui.checkbox("midi.constantVolume", a.midi.constantVolume, text.midiConstantVolume)

	local m = settings.miscellaneous
	m.muteOnUnfocus = imgui.checkbox("muteOnUnfocus", m.muteOnUnfocus, text.muteOnUnfocus)

	imgui.separator()
	gyatt.text(text.audioDevice)
	just.next(0, textSeparation)

	local audioInfo = audio.getInfo()
	gyatt.text(text.latency .. audioInfo.latency .. "ms")
	just.next(0, textSeparation)
	a.device.period = imgui.slider1("d.period", a.device.period, "%dms", 1, 50, 1, text.updatePeriod)
	a.device.buffer = imgui.slider1("d.buffer", a.device.buffer, "%dms", 1, 50, 1, text.bufferLength)
	a.adjustRate = imgui.slider1("a.adjustRate", a.adjustRate, "%0.2f", 0, 1, 0.01, text.adjustRate)

	if imgui.button("apply device", text.apply) then
		audio.setDevicePeriod(a.device.period)
		audio.setDeviceBuffer(a.device.buffer)
		audio.reinit()
	end
	just.sameline()
	if imgui.button("reset device", text.reset) then
		a.device.period = audio.default_dev_period
		a.device.buffer = audio.default_dev_buffer
		audio.setDevicePeriod(a.device.period)
		audio.setDeviceBuffer(a.device.buffer)
		audio.reinit()
	end
end

---@param mode table
---@return string
local function formatMode(mode)
	return mode.width .. "x" .. mode.height
end

local vsyncNames = {
	[1] = "enabled",
	[0] = "disabled",
	[-1] = "adaptive",
}

---@param v number?
---@return string
local function formatVsync(v)
	return text[vsyncNames[v]] or ""
end

---@param v number?
---@return string
local function formatFullscreenType(v)
	return text[v] or ""
end

---@param v number?
---@return string
local function formatCursor(v)
	return text[v] or ""
end

function SettingsTab:Video(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.graphics
	local gp = settings.gameplay

	gyatt.text(text.videoTab)
	just.next(0, textSeparation)

	g.fps = imgui.intButtons("fps", g.fps, 2, text.fpsLimit)

	local flags = g.mode.flags

	flags.fullscreentype = imgui.combo(
		"flags.fst",
		flags.fullscreentype,
		{ "desktop", "exclusive" },
		formatFullscreenType,
		text.fullscreenType
	)
	self.modes = self.modes or love.window.getFullscreenModes()
	g.mode.window = imgui.combo("mode.window", g.mode.window, self.modes, formatMode, text.startupWindowResolution)
	flags.vsync = imgui.combo("flags.vsync", flags.vsync, { 1, 0, -1 }, formatVsync, text.vsync)
	flags.msaa = imgui.combo("flags.msaa", flags.msaa, { 0, 1, 2, 4, 8, 16 }, nil, "MSAA")
	flags.fullscreen = imgui.checkbox("flags.fullscreen", flags.fullscreen, text.fullscreen)
	g.vsyncOnSelect = imgui.checkbox("vsyncOnSelect", g.vsyncOnSelect, text.vsyncOnSelect)
	g.dwmflush = imgui.checkbox("dwmflush", g.dwmflush, text.dwmFlush)

	imgui.separator()
	gyatt.text(text.backgroundAnimation)
	just.next(0, textSeparation)
	gp.bga.video = imgui.checkbox("bga.video", gp.bga.video, text.video)
	gp.bga.image = imgui.checkbox("bga.image", gp.bga.image, text.image)

	imgui.separator()
	gyatt.text(text.camera)
	just.next(0, textSeparation)
	local p = g.perspective
	p.camera = imgui.checkbox("p.camera", p.camera, text.enableCamera)
	p.rx = imgui.checkbox("p.rx", p.rx, text.allowRotateX)
	p.ry = imgui.checkbox("p.ry", p.ry, text.allowRotateY)
end

function SettingsTab:Inputs(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.graphics

	gyatt.text(text.inputsTab)
	just.next(0, textSeparation)
	g.asynckey = imgui.checkbox("asynckey", g.asynckey, text.threadedInput)

	local playContext = view.game.playContext
	playContext.single = imgui.checkbox("single", playContext.single, text.singleNoteHandler)

	imgui.separator()
	gyatt.text(text.gameplayInputs)
	just.next(0, textSeparation)
	love.graphics.translate(-15, 0)
	inputListView:draw(panelW, panelH, true)
end

local diff_columns = {
	"enps_diff",
	"osu_diff",
	"msd_diff",
	"user_diff",
}

local diff_columns_names = {
	enps_diff = "ENPS",
	osu_diff = "OSU",
	msd_diff = "MSD",
	user_diff = "USER",
}

local function formatDiffColumnName(v)
	return diff_columns_names[v] or ""
end

---@param v number?
---@return string
local function formatRateType(v)
	return text[v] or ""
end

local function formatColorType(v)
	return text[v] or ""
end

local function formatLocalization(v)
	return v.name
end

local function formatTranisiton(v)
	return text[v] or ""
end

function SettingsTab:UI(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.graphics
	local gp = configs.settings.gameplay
	local ss = settings.select
	local m = settings.miscellaneous
	local irizz = configs.irizz

	local timeRateModel = view.game.timeRateModel

	gyatt.text(text.select)
	just.next(0, textSeparation)
	ss.chart_preview = imgui.checkbox("ss.chart_preview", ss.chart_preview, text.chartPreview)
	irizz.showOnlineCount = imgui.checkbox("irizz.showOnline", irizz.showOnlineCount, text.showOnlineCount)
	ss.collapse = imgui.checkbox("ss.collapse", ss.collapse, text.groupCharts)
	m.showNonManiaCharts = imgui.checkbox("showNonManiaCharts", m.showNonManiaCharts, text.showNonManiaCharts)
	irizz.alwaysShowOriginalMode =
		imgui.checkbox("irizz.originalMode", irizz.alwaysShowOriginalMode, text.alwaysShowOriginalMode)

	ss.diff_column = imgui.combo("diff_column", ss.diff_column, diff_columns, formatDiffColumnName, text.difficulty)

	--[[
	local currentLanguage = irizz.language
	local newLanguage =
		imgui.combo("irizz.language", irizz.language, Theme.localizations, formatLocalization, text.language)

	if currentLanguage ~= newLanguage then
		irizz.language = newLanguage.name
		assets:loadLocalization(newLanguage.fileName, Theme)
		view.game.selectView:changeScreen("selectView")
	end
	]]

	local rateType = imgui.combo("rate_type", gp.rate_type, timeRateModel.types, formatRateType, text.rateType)
	if rateType ~= gp.rate_type then
		view.game.modifierSelectModel:change()
		gp.rate_type = rateType

		local rate = rateType == "exp" and 0 or 1
		timeRateModel:set(rate)
	end

	irizz.songSelectOffset =
		imgui.slider1("irizz.songSelectOffset", irizz.songSelectOffset, "%0.02f", -1, 1, 0.01, text.songSelectOffset)

	imgui.separator()
	gyatt.text(text.effects)
	just.next(0, textSeparation)
	irizz.showSpectrum = imgui.checkbox("irizz.showSpectrum", irizz.showSpectrum, text.showSpectrum)
	irizz.backgroundEffects = imgui.checkbox("irizz.backgroundEffects", irizz.backgroundEffects, text.backgroundEffects)
	irizz.panelBlur = imgui.slider1("irizz.panelBlur", irizz.panelBlur, "%i", 0, 10, 1, text.panelBlur)
	irizz.chromatic_aberration = imgui.slider1(
		"irizz.ch_ab",
		irizz.chromatic_aberration * 1000,
		"%i%%",
		0,
		100,
		1,
		text.ch_ab
	) / 1000

	irizz.distortion = imgui.slider1("irizz.distortion", irizz.distortion * 1000, "%i%%", 0, 100, 1, text.distortion)
		/ 1000

	irizz.spectrum =
		imgui.combo("irizz.spectrum", irizz.spectrum, { "solid", "inverted" }, formatColorType, text.spectrum)

	irizz.transitionAnimation = imgui.combo(
		"irizz.transitionAnimation",
		irizz.transitionAnimation,
		{ "circle", "fade", "shutter" },
		formatTranisiton,
		text.transitionAnimation
	)

	imgui.separator()
	gyatt.text(text.collections)
	just.next(0, textSeparation)
	local changed = false
	ss.locations_in_collections, changed =
		imgui.checkbox("s.locations_in_collections", ss.locations_in_collections, text.showLocations)

	if changed then
		view.game.selectModel.collectionLibrary:load(ss.locations_in_collections)
	end

	imgui.separator()
	gyatt.text(text.uiTab)
	just.next(0, textSeparation)

	changed = false
	irizz.vimMotions, changed = imgui.checkbox("irizz.vimMotions", irizz.vimMotions, text.vimMotions)

	if changed then
		view.game.actionModel:updateActions()
	end

	irizz.staticCursor = imgui.checkbox("irizz.staticCursor", irizz.staticCursor, text.staticCursor)
	irizz.scrollAcceleration =
		imgui.checkbox("irizz.scrollAcceleration", irizz.scrollAcceleration, text.scrollAcceleration)

	irizz.scrollClickExtraTime = imgui.slider1(
		"irizz.scrollClickExtraTime",
		irizz.scrollClickExtraTime,
		"%0.2f",
		0,
		0.25,
		0.01,
		text.scrollClickExtraTime
	)

	local colorTheme = irizz.colorTheme
	local newColorTheme = imgui.combo("irizz.colorTheme", colorTheme, color_themes, nil, text.colorTheme)

	if colorTheme ~= newColorTheme then
		irizz.colorTheme = newColorTheme
		self.assets:loadColorTheme(newColorTheme)
	end

	g.cursor = imgui.combo("g.cursor", g.cursor, { "circle", "arrow", "system" }, formatCursor, text.cursor)
	irizz.startSound = imgui.combo("irizz.startSound", irizz.startSound, start_sound_names, nil, text.startSound)

	imgui.separator()
	gyatt.text(text.osuSongSelect)
	just.next(0, textSeparation)

	local load_new_ui = false
	local load_new_skin = false

	irizz.osuSongSelect, load_new_ui = imgui.checkbox("irizz.osuSongSelect", irizz.osuSongSelect, text.enable)
	irizz.osuSongSelectPreviewIcon =
		imgui.checkbox("irizz.osuSongSelectPreviewIcon", irizz.osuSongSelectPreviewIcon, text.previewIcon)
	irizz.osuSongSelectSkin, load_new_skin =
		imgui.combo("irizz.osuSongSelectSkin", irizz.osuSongSelectSkin, osu_skins, nil, text.skin)

	if load_new_ui then
		---@type skibidi.ScreenView
		local select_view

		if irizz.osuSongSelect then
			select_view = require("thetan.osu.views.SelectView")
		else
			select_view = require("thetan.irizz.views.SelectView")
		end

		local current_view = view.game.selectView

		view.game.ui.selectView = select_view(view.game)
		view.game.selectView = view.game.ui.selectView
		current_view:changeScreen("selectView")
	end

	if load_new_skin and irizz.osuSongSelect then
		local current_view = view.game.selectView
		current_view:changeScreen("selectView")
	end

	imgui.separator()
	gyatt.text(text.osuResultScreen)
	just.next(0, textSeparation)

	local change_result_screen = false

	irizz.osuResultScreen, change_result_screen =
		imgui.checkbox("irizz.osuResultScreen", irizz.osuResultScreen, text.enable)
	irizz.hpGraph = imgui.checkbox("irizz.hpGraph", irizz.hpGraph, text.showHpGraph)
	irizz.showPP = imgui.checkbox("irizz.showPP", irizz.showPP, text.showPP)

	if change_result_screen then
		---@type skibidi.ScreenView
		local result_view

		if irizz.osuResultScreen then
			result_view = require("thetan.osu.views.ResultView")
		else
			result_view = require("thetan.irizz.views.ResultView")
		end

		view.game.ui.resultView = result_view(view.game)
		view.game.resultView = view.game.ui.resultView
	end

	imgui.separator()

	gyatt.text(text.dim)
	just.next(0, textSeparation)
	local dim = g.dim
	dim.select = imgui.slider1("dim.select", dim.select, "%0.2f", 0, 1, 0.01, text.select)
	dim.gameplay = imgui.slider1("dim.gameplay", dim.gameplay, "%0.2f", 0, 1, 0.01, text.gameplay)
	dim.result = imgui.slider1("dim.result", dim.result, "%0.2f", 0, 1, 0.01, text.result)

	imgui.separator()
	gyatt.text(text.blur)
	just.next(0, textSeparation)
	local blur = g.blur
	blur.select = imgui.slider1("blur.select", blur.select, "%d", 0, 20, 1, text.select)
	blur.gameplay = imgui.slider1("blur.gameplay", blur.gameplay, "%d", 0, 20, 1, text.gameplay)
	blur.result = imgui.slider1("blur.result", blur.result, "%d", 0, 20, 1, text.result)
end

function SettingsTab:Version(view)
	imgui.separator()
	local settings = view.game.configModel.configs.settings
	local m = settings.miscellaneous
	just.next(0, textSeparation)
	m.autoUpdate = imgui.checkbox("autoUpdate", m.autoUpdate, text.autoUpdate)

	imgui.separator()
	if NOESIS_INSTALLED then
		gyatt.text("Noesis: " .. NOESIS_VERSION)
	end

	if IRIZZ_VERSION then
		gyatt.text("Irizz theme: " .. IRIZZ_VERSION)
	end

	gyatt.text(text.commit .. version.commit)
	gyatt.text(text.commitDate .. version.date)

	imgui.separator()
	gyatt.text(text.contributors)
	gyatt.text("semyon422 - For making soundsphere")
	gyatt.text("iyase - Translating to Japanese and fixing mistakes")
	gyatt.text("Floob1nk - Translating to Russian")
	gyatt.text("GPT 4 - Translating to Japanese (poorly)")

	gyatt.next(0, textSeparation)
	gyatt.text("Noesis:")
	gyatt.text("iyase - For allowing to use their skin")
	gyatt.text("KcHecKa - For allowing to use their skin")
end

return SettingsTab
