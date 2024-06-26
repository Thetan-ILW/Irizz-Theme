local class = require("class")

local just = require("just")
local imgui = require("thetan.irizz.imgui")
local table_util = require("table_util")
local Container = require("thetan.gyatt.Container")
local audio = require("audio")
local version = require("version")

local assets = require("thetan.irizz.assets")
local Theme = require("thetan.irizz.views.Theme")
local Text = Theme.textSettings
local cfg = Theme.imgui

local InputListView = require("thetan.irizz.views.modals.InputModal.InputListView")

local SettingsTab = class()

local textSeparation = 15
local panelW = 0
local panelH = 0
local inputListView

SettingsTab.container = Container("settingsContainer")

function SettingsTab:new(game)
	inputListView = InputListView(game)
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

	Theme:setLines()
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
	return Text[v] or ""
end

---@param v number?
---@return string
local function formatSpeedType(v)
	return Text[v] or ""
end

---@param v number?
---@return string
local function formatTempoFactor(v)
	return Text[v] or ""
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

	just.text(Text.scrollSpeed)
	just.next(0, textSeparation)

	local newSpeed = imgui.slider1(
		"speed",
		speedModel:get(),
		speedFormat,
		speedRange[1],
		speedRange[2],
		speedRange[3],
		Text.scrollSpeed
	)
	speedModel:set(newSpeed)

	g.speedType = imgui.combo("speedType", g.speedType, speedModel.types, formatSpeedType, Text.speedType)

	g.longNoteShortening = imgui.slider1(
		"shortening",
		g.longNoteShortening * 1000,
		"%dms",
		-300,
		0,
		10,
		Text.lnShortening
	) / 1000

	g.tempoFactor = imgui.combo(
		"tempoFactor",
		g.tempoFactor,
		{ "average", "primary", "minimum", "maximum" },
		formatTempoFactor,
		Text.tempoFactor
	)
	if g.tempoFactor == "primary" then
		g.primaryTempo = imgui.slider1("primaryTempo", g.primaryTempo, Text.bpm, 60, 240, 1, Text.primaryTempo)
	end

	g.swapVelocityType = imgui.checkbox("swapVelocityType", g.swapVelocityType, Text.taikoSV)

	if not g.swapVelocityType then
		g.scaleSpeed = imgui.checkbox("scaleSpeed", g.scaleSpeed, Text.scaleScrollSpeed)
	end
	g.eventBasedRender = g.swapVelocityType
	g.scaleSpeed = g.swapVelocityType and true or g.scaleSpeed
	local playContext = view.game.playContext
	playContext.const = imgui.checkbox("const", playContext.const, Text.const)

	imgui.separator()
	just.text(Text.waitTime)
	just.next(0, textSeparation)
	g.time.prepare = imgui.slider1("time.prepare", g.time.prepare, "%0.1f", 0.5, 3, 0.1, Text.prepare)
	g.time.playPause = imgui.slider1("time.playPause", g.time.playPause, "%0.1f", 0, 2, 0.1, Text.playPause)
	g.time.playRetry = imgui.slider1("time.playRetry", g.time.playRetry, "%0.1f", 0, 2, 0.1, Text.playRetry)
	g.time.pausePlay = imgui.slider1("time.pausePlay", g.time.pausePlay, "%0.1f", 0, 2, 0.1, Text.pausePlay)
	g.time.pauseRetry = imgui.slider1("time.pauseRetry", g.time.pauseRetry, "%0.1f", 0, 2, 0.1, Text.pauseRetry)

	local input_mode = tostring(view.game.selectController.state.inputMode)

	if input_mode ~= "" then
		imgui.separator()
		just.text(Text.noteSkin)
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
			irizz.judge = imgui.combo("irizz.judge", irizz.judge, judges, formatLunaticRave, Text.judgement)
		else
			irizz.judge = imgui.combo("irizz.judge", irizz.judge, judges, nil, Text.judgement)
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
	note.hit[1] = noteTiming(note.hit[1], 0, false, hitLabel .. Text.early)
	note.miss[1] = noteTiming(note.miss[1], note.hit[1], false, missLabel .. Text.early)
	note.hit[2] = noteTiming(note.hit[2], 0, true, hitLabel .. Text.late)
	note.miss[2] = noteTiming(note.miss[2], note.hit[2], true, missLabel .. Text.late)
end

function SettingsTab:Scoring(view)
	local configs = view.game.configModel.configs
	local select = configs.select
	local irizz = configs.irizz
	local settings = configs.settings
	local g = settings.gameplay

	imgui.separator()
	just.text(Text.scoring)
	just.next(0, textSeparation)

	local prevScoreSystem = irizz.scoreSystem
	irizz.scoreSystem = imgui.combo("irizz.scoreSystem", irizz.scoreSystem, scoreSystems, nil, Text.scoreSystem)

	scoreSystem(prevScoreSystem ~= irizz.scoreSystem, irizz.scoreSystem, irizz, select, view.game.playContext)
	local noteTimings = view.game.playContext.timings
	noteTimings.nearest = imgui.checkbox("timings.nearest", noteTimings.nearest, Text.nearest)

	local note = noteTimings.ShortNote
	local ln = noteTimings.LongNoteStart
	local release = noteTimings.LongNoteEnd

	imgui.separator()
	noteTimingGroup(note, Text.noteHitWindow, Text.noteMissWindow)
	imgui.separator()
	noteTimingGroup(ln, Text.lnHitWindow, Text.lnMissWindow)
	imgui.separator()
	noteTimingGroup(release, Text.releaseHitWindow, Text.releaseMissWindow)

	imgui.separator()
	just.text(Text.hp)
	just.next(0, textSeparation)
	g.hp.shift = imgui.checkbox("hp.shift", g.hp.shift, Text.hpShift)
	g.hp.notes = math.min(math.max(imgui.intButtons("hp.notes", g.hp.notes, 1, Text.hpNotes), 0), 100)
	g.actionOnFail =
		imgui.combo("actionOnFail", g.actionOnFail, { "none", "pause", "quit" }, formatActionOnFail, Text.actionOnFail)

	imgui.separator()
	just.text(Text.other)
	just.next(0, textSeparation)
	g.ratingHitTimingWindow = intButtonsMs("ratingHitTimingWindow", g.ratingHitTimingWindow, Text.ratingHitWindow)
	g.lastMeanValues = imgui.intButtons("lastMeanValues", g.lastMeanValues, 1, Text.lastMeanValues)
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

	just.text(Text.timingsTab)
	just.next(0, textSeparation)

	g.offset.input = intButtonsMs("input offset", g.offset.input, Text.inputOffest)
	g.offset.visual = intButtonsMs("visual offset", g.offset.visual, Text.visualOffset)
	g.offsetScale.input = imgui.checkbox("offsetScale.input", g.offsetScale.input, Text.multiplyInputOffset)
	g.offsetScale.visual = imgui.checkbox("offsetScale.visual", g.offsetScale.visual, Text.multiplyVisualOffset)

	imgui.separator()
	imgui.text(Text.chartFormatOffsets)
	just.next(0, textSeparation)

	for _, format in ipairs(formats) do
		of[format] = intButtonsMs("offset " .. format, of[format], format)
	end

	imgui.separator()
	imgui.text(Text.audioModeOffsets)
	just.next(0, textSeparation)

	for _, audio_mode in ipairs(audio_modes) do
		oam[audio_mode] = intButtonsMs("offset " .. audio_mode, oam[audio_mode], formatModes(audio_mode))
	end
end

---@param mode string
---@return string
local function formatVolumeType(mode)
	return Text[mode] or ""
end

function SettingsTab:Audio(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local irizz = configs.irizz
	local a = settings.audio
	local g = settings.gameplay

	just.text(Text.volume)
	just.next(0, textSeparation)

	a.volumeType =
		imgui.combo("a.volumeType", a.volumeType, { "linear", "logarithmic" }, formatVolumeType, Text.volumeType)

	local v = a.volume

	local oldMaster = v.master
	local oldUi = irizz.uiVolume

	if a.volumeType == "linear" then
		v.master = imgui.slider1("v.master", v.master * 100, "%i%%", 0, 100, 1, Text.master) / 100
		v.music = imgui.slider1("v.music", v.music * 100, "%i%%", 0, 100, 1, Text.music) / 100
		v.effects = imgui.slider1("v.effects", v.effects * 100, "%i%%", 0, 100, 1, Text.effects) / 100
		v.metronome = imgui.slider1("v.metronome", v.metronome * 100, "%i%%", 0, 100, 1, Text.metronome) / 100
		irizz.uiVolume = imgui.slider1("irizz.uiVolume", irizz.uiVolume * 100, "%i%%", 0, 100, 1, Text.uiVolume) / 100
	elseif a.volumeType == "logarithmic" then
		v.master = imgui.lfslider("v.master", v.master, "%ddB", -60, 0, 1, Text.master)
		v.music = imgui.lfslider("v.music", v.music, "%ddB", -60, 0, 1, Text.music)
		v.effects = imgui.lfslider("v.effects", v.effects, "%ddB", -60, 0, 1, Text.effects)
		v.metronome = imgui.lfslider("v.metronome", v.metronome, "%ddB", -60, 0, 1, Text.metronome)
		irizz.uiVolume = imgui.lfslider("irizz.uiVolume", irizz.uiVolume, "%ddB", -60, 0, 1, Text.uiVolume)
	end

	if v.master ~= oldMaster or irizz.uiVolume ~= oldUi then
		Theme:updateVolume(view.game)
	end

	local mode = a.mode

	local pitch = mode.primary == "bass_sample" and true or false
	pitch = imgui.checkbox("audioPitch", pitch, Text.audioPitch)

	local audioMode = pitch and "bass_sample" or "bass_fx_tempo"

	mode.primary = audioMode
	mode.secondary = audioMode

	g.autoKeySound = imgui.checkbox("autoKeySound", g.autoKeySound, Text.autoKeySound)
	a.midi.constantVolume = imgui.checkbox("midi.constantVolume", a.midi.constantVolume, Text.midiConstantVolume)

	local m = settings.miscellaneous
	m.muteOnUnfocus = imgui.checkbox("muteOnUnfocus", m.muteOnUnfocus, Text.muteOnUnfocus)

	imgui.separator()
	just.text(Text.audioDevice)
	just.next(0, textSeparation)

	local audioInfo = audio.getInfo()
	just.text(Text.latency .. audioInfo.latency .. "ms")
	just.next(0, textSeparation)
	a.device.period = imgui.slider1("d.period", a.device.period, "%dms", 1, 50, 1, Text.updatePeriod)
	a.device.buffer = imgui.slider1("d.buffer", a.device.buffer, "%dms", 1, 50, 1, Text.bufferLength)
	a.adjustRate = imgui.slider1("a.adjustRate", a.adjustRate, "%0.2f", 0, 1, 0.01, Text.adjustRate)

	if imgui.button("apply device", Text.apply) then
		audio.setDevicePeriod(a.device.period)
		audio.setDeviceBuffer(a.device.buffer)
		audio.reinit()
	end
	just.sameline()
	if imgui.button("reset device", Text.reset) then
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
	return Text[vsyncNames[v]] or ""
end

---@param v number?
---@return string
local function formatFullscreenType(v)
	return Text[v] or ""
end

---@param v number?
---@return string
local function formatCursor(v)
	return Text[v] or ""
end

function SettingsTab:Video(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.graphics
	local gp = settings.gameplay

	just.text(Text.videoTab)
	just.next(0, textSeparation)

	g.fps = imgui.intButtons("fps", g.fps, 2, Text.fpsLimit)

	local flags = g.mode.flags

	flags.fullscreentype = imgui.combo(
		"flags.fst",
		flags.fullscreentype,
		{ "desktop", "exclusive" },
		formatFullscreenType,
		Text.fullscreenType
	)
	self.modes = self.modes or love.window.getFullscreenModes()
	g.mode.window = imgui.combo("mode.window", g.mode.window, self.modes, formatMode, Text.startupWindowResolution)
	flags.vsync = imgui.combo("flags.vsync", flags.vsync, { 1, 0, -1 }, formatVsync, Text.vsync)
	flags.msaa = imgui.combo("flags.msaa", flags.msaa, { 0, 1, 2, 4, 8, 16 }, nil, "MSAA")
	flags.fullscreen = imgui.checkbox("flags.fullscreen", flags.fullscreen, Text.fullscreen)
	g.vsyncOnSelect = imgui.checkbox("vsyncOnSelect", g.vsyncOnSelect, Text.vsyncOnSelect)
	g.dwmflush = imgui.checkbox("dwmflush", g.dwmflush, Text.dwmFlush)

	imgui.separator()
	just.text(Text.backgroundAnimation)
	just.next(0, textSeparation)
	gp.bga.video = imgui.checkbox("bga.video", gp.bga.video, Text.video)
	gp.bga.image = imgui.checkbox("bga.image", gp.bga.image, Text.image)

	imgui.separator()
	just.text(Text.camera)
	just.next(0, textSeparation)
	local p = g.perspective
	p.camera = imgui.checkbox("p.camera", p.camera, Text.enableCamera)
	p.rx = imgui.checkbox("p.rx", p.rx, Text.allowRotateX)
	p.ry = imgui.checkbox("p.ry", p.ry, Text.allowRotateY)
end

function SettingsTab:Inputs(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.graphics

	just.text(Text.inputsTab)
	just.next(0, textSeparation)
	g.asynckey = imgui.checkbox("asynckey", g.asynckey, Text.threadedInput)

	local playContext = view.game.playContext
	playContext.single = imgui.checkbox("single", playContext.single, Text.singleNoteHandler)

	imgui.separator()
	just.text(Text.gameplayInputs)
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

---@param v number?
---@return string
local function formatRateType(v)
	return Text[v] or ""
end

local function formatColorType(v)
	return Text[v] or ""
end

local function formatLocalization(v)
	return v.name
end

local function formatTranisiton(v)
	return Text[v] or ""
end

function SettingsTab:UI(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local s = configs.select
	local g = settings.graphics
	local gp = configs.settings.gameplay
	local ss = settings.select
	local m = settings.miscellaneous
	local irizz = configs.irizz

	local timeRateModel = view.game.timeRateModel

	just.text(Text.select)
	just.next(0, textSeparation)
	irizz.showOnlineCount = imgui.checkbox("irizz.showOnline", irizz.showOnlineCount, Text.showOnlineCount)
	s.collapse = imgui.checkbox("s.collapse", s.collapse, Text.groupCharts)
	m.showNonManiaCharts = imgui.checkbox("showNonManiaCharts", m.showNonManiaCharts, Text.showNonManiaCharts)
	irizz.alwaysShowOriginalMode =
		imgui.checkbox("irizz.originalMode", irizz.alwaysShowOriginalMode, Text.alwaysShowOriginalMode)

	irizz.chartLengthBeforeArtist =
		imgui.checkbox("irizz.chartLengthBeforeArtist", irizz.chartLengthBeforeArtist, Text.chartLengthBeforeArtist)
	ss.diff_column = imgui.combo("diff_column", ss.diff_column, diff_columns, Theme.formatDiffColumns, Text.difficulty)

	local currentLanguage = irizz.language
	local newLanguage =
		imgui.combo("irizz.language", irizz.language, Theme.localizations, formatLocalization, Text.language)

	if currentLanguage ~= newLanguage then
		irizz.language = newLanguage.name
		assets:loadLocalization(newLanguage.fileName, Theme)
	end

	local rateType = imgui.combo("rate_type", gp.rate_type, timeRateModel.types, formatRateType, Text.rateType)
	if rateType ~= gp.rate_type then
		view.game.modifierSelectModel:change()
		gp.rate_type = rateType

		local rate = rateType == "exp" and 0 or 1
		timeRateModel:set(rate)
	end

	imgui.separator()
	just.text(Text.effects)
	just.next(0, textSeparation)
	irizz.showSpectrum = imgui.checkbox("irizz.showSpectrum", irizz.showSpectrum, Text.showSpectrum)
	irizz.backgroundEffects = imgui.checkbox("irizz.backgroundEffects", irizz.backgroundEffects, Text.backgroundEffects)
	irizz.panelBlur = imgui.slider1("irizz.panelBlur", irizz.panelBlur, "%i", 0, 10, 1, Text.panelBlur)
	irizz.chromatic_aberration = imgui.slider1(
		"irizz.ch_ab",
		irizz.chromatic_aberration * 1000,
		"%i%%",
		0,
		100,
		1,
		Text.ch_ab
	) * 0.001

	irizz.distortion = imgui.slider1("irizz.distortion", irizz.distortion * 1000, "%i%%", 0, 100, 1, Text.distortion)
		* 0.001

	irizz.spectrum =
		imgui.combo("irizz.spectrum", irizz.spectrum, { "solid", "inverted" }, formatColorType, Text.spectrum)

	irizz.transitionAnimation = imgui.combo(
		"irizz.transitionAnimation",
		irizz.transitionAnimation,
		{ "circle", "fade", "shutter" },
		formatTranisiton,
		Text.transitionAnimation
	)

	imgui.separator()
	just.text(Text.collections)
	just.next(0, textSeparation)
	local changed = false
	ss.locations_in_collections, changed =
		imgui.checkbox("s.locations_in_collections", ss.locations_in_collections, Text.showLocations)

	if changed then
		view.game.selectModel.collectionLibrary:load(ss.locations_in_collections)
	end

	imgui.separator()
	just.text(Text.uiTab)
	just.next(0, textSeparation)

	changed = false
	irizz.vimMotions, changed = imgui.checkbox("irizz.vimMotions", irizz.vimMotions, Text.vimMotions)

	if changed then
		view.game.actionModel:updateActions()
	end

	irizz.staticCursor = imgui.checkbox("irizz.staticCursor", irizz.staticCursor, Text.staticCursor)
	irizz.scrollAcceleration =
		imgui.checkbox("irizz.scrollAcceleration", irizz.scrollAcceleration, Text.scrollAcceleration)

	irizz.scrollClickExtraTime = imgui.slider1(
		"irizz.scrollClickExtraTime",
		irizz.scrollClickExtraTime,
		"%0.2f",
		0,
		0.25,
		0.01,
		Text.scrollClickExtraTime
	)

	local colorTheme = irizz.colorTheme
	local newColorTheme = imgui.combo("irizz.colorTheme", colorTheme, Theme.colorThemes, nil, Text.colorTheme)

	if colorTheme ~= newColorTheme then
		irizz.colorTheme = newColorTheme
		assets:updateColorTheme(newColorTheme, Theme)
	end

	g.cursor = imgui.combo("g.cursor", g.cursor, { "circle", "arrow", "system" }, formatCursor, Text.cursor)
	irizz.startSound = imgui.combo("irizz.startSound", irizz.startSound, Theme.sounds.startNames, nil, Text.startSound)

	imgui.separator()
	just.text(Text.osuResultScreen)
	just.next(0, textSeparation)

	irizz.osuResultScreen = imgui.checkbox("irizz.osuResultScreen", irizz.osuResultScreen, Text.enable)
	irizz.hpGraph = imgui.checkbox("irizz.hpGraph", irizz.hpGraph, Text.showHpGraph)
	irizz.showPP = imgui.checkbox("irizz.showPP", irizz.showPP, Text.showPP)

	if #Theme.osuSkinNames == 0 then
		Theme.osuSkinNames = { "None" }
	end

	irizz.osuResultSkin = imgui.combo("irizz.osuResultSkin", irizz.osuResultSkin, Theme.osuSkinNames, nil, Text.skin)

	imgui.separator()

	just.text(Text.dim)
	just.next(0, textSeparation)
	local dim = g.dim
	dim.select = imgui.slider1("dim.select", dim.select, "%0.2f", 0, 1, 0.01, Text.select)
	dim.gameplay = imgui.slider1("dim.gameplay", dim.gameplay, "%0.2f", 0, 1, 0.01, Text.gameplay)
	dim.result = imgui.slider1("dim.result", dim.result, "%0.2f", 0, 1, 0.01, Text.result)

	imgui.separator()
	just.text(Text.blur)
	just.next(0, textSeparation)
	local blur = g.blur
	blur.select = imgui.slider1("blur.select", blur.select, "%d", 0, 20, 1, Text.select)
	blur.gameplay = imgui.slider1("blur.gameplay", blur.gameplay, "%d", 0, 20, 1, Text.gameplay)
	blur.result = imgui.slider1("blur.result", blur.result, "%d", 0, 20, 1, Text.result)
end

function SettingsTab:Version(view)
	imgui.separator()
	local settings = view.game.configModel.configs.settings
	local m = settings.miscellaneous
	just.next(0, textSeparation)
	m.autoUpdate = imgui.checkbox("autoUpdate", m.autoUpdate, Text.autoUpdate)

	imgui.separator()
	if NOESIS_INSTALLED then
		just.text("Noesis: " .. NOESIS_VERSION)
	end

	if IRIZZ_VERSION then
		just.text("Irizz theme: " .. IRIZZ_VERSION)
	end

	just.text(Text.commit .. version.commit)
	just.text(Text.commitDate .. version.date)

	imgui.separator()
	just.text(Text.contributors)
	just.text("iyase - Translating to Japanese and fixing mistakes")
	just.text("floob1nk - Translating to Russian")
end

return SettingsTab
