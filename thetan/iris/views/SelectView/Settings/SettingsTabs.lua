local just = require("just")
local imgui = require("thetan.iris.imgui")
local flux = require("flux")
local math_util = require("math_util")
local audio = require("audio")
local version = require("version")

local Theme = require("thetan.iris.views.Theme")
local Text = Theme.textSettings
local cfg = Theme.imgui

local SettingsTab = {}

local textSeparation = 15
SettingsTab.scroll = 0
SettingsTab.scrollTarget = 0
SettingsTab.tween = flux.to(SettingsTab, 0, { scroll = 0 })
SettingsTab.startSounds = nil

function SettingsTab:reset()
	self.scroll = 0
	self.scrollTarget = 0
	self.tween:stop()
	just.reset()
end

function SettingsTab:draw(view, w, h, tab)
	local scrollLimit = just.height

	local delta = just.wheel_over(tab, just.is_over(w, h))
	if delta then
		self.scrollTarget = self.scrollTarget + (delta * 80)
		self.scrollTarget = math_util.clamp(-scrollLimit, self.scrollTarget, 0)
		self.tween = flux.to(self, 0.25, { scroll = self.scrollTarget }):ease("quartout")
	end

	imgui.setSize(w, h, w / 2.5, cfg.size)

	just.clip(love.graphics.rectangle, "fill", 0, 0, w, h)
	love.graphics.translate(15, self.scroll + 15)

	Theme:setLines()

	self[tab](self, view)
	just.clip()
end

---@param id any
---@param v number
---@param label string
---@return number
local function intButtonsMs(id, v, label)
	return imgui.intButtons(id, v * 1000, 1, label) / 1000
end

local speedType = {
	["default"] = Text.default,
	["osu"] = Text.osu,
}

local actionOnFail = {
	["none"] = Text.none,
	["pause"] = Text.pause,
	["quit"] = Text.quit,
}

local tempoFactor = {
	["average"] = Text.average,
	["primary"] = Text.primary,
	["minimum"] = Text.minimum,
	["maximum"] = Text.maximum,
}

---@param v number?
---@return string
local function formatActionOnFail(v)
	return actionOnFail[v] or ""
end

---@param v number?
---@return string
local function formatSpeedType(v)
	return speedType[v] or ""
end

---@param v number?
---@return string
local function formatTempoFactor(v)
	return tempoFactor[v] or ""
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
	just.text(Text.hp)
	just.next(0, textSeparation)
	g.hp.shift = imgui.checkbox("hp.shift", g.hp.shift, Text.hpShift)
	g.hp.notes = math.min(math.max(imgui.intButtons("hp.notes", g.hp.notes, 1, Text.hpNotes), 0), 100)
	g.actionOnFail =
		imgui.combo("actionOnFail", g.actionOnFail, { "none", "pause", "quit" }, formatActionOnFail, Text.actionOnFail)

	imgui.separator()
	just.text(Text.waitTime)
	just.next(0, textSeparation)
	g.time.prepare = imgui.slider1("time.prepare", g.time.prepare, "%0.1f", 0.5, 3, 0.1, Text.prepare)
	g.time.playPause = imgui.slider1("time.playPause", g.time.playPause, "%0.1f", 0, 2, 0.1, Text.playPause)
	g.time.playRetry = imgui.slider1("time.playRetry", g.time.playRetry, "%0.1f", 0, 2, 0.1, Text.playRetry)
	g.time.pausePlay = imgui.slider1("time.pausePlay", g.time.pausePlay, "%0.1f", 0, 2, 0.1, Text.pausePlay)
	g.time.pauseRetry = imgui.slider1("time.pauseRetry", g.time.pauseRetry, "%0.1f", 0, 2, 0.1, Text.pauseRetry)

	imgui.separator()
	just.text(Text.other)
	just.next(0, textSeparation)
	g.lastMeanValues = imgui.intButtons("lastMeanValues", g.lastMeanValues, 1, Text.lastMeanValues)
end

function SettingsTab:Timings(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local g = settings.gameplay

	just.text(Text.timingsTab)
	just.next(0, textSeparation)

	g.ratingHitTimingWindow = intButtonsMs("ratingHitTimingWindow", g.ratingHitTimingWindow, Text.ratingHitWindow)
	g.offset.input = intButtonsMs("input offset", g.offset.input, Text.inputOffest)
	g.offset.visual = intButtonsMs("visual offset", g.offset.visual, Text.visualOffset)
	g.offsetScale.input = imgui.checkbox("offsetScale.input", g.offsetScale.input, Text.multiplyInputOffset)
	g.offsetScale.visual = imgui.checkbox("offsetScale.visual", g.offsetScale.visual, Text.multiplyVisualOffset)
end

local _formatModes = {
	bass_sample = "bass sample",
	bass_fx_tempo = "bass fx tempo",
}

local volumeType = {
	["linear"] = Text.linearType,
	["logarithmic"] = Text.logarithmicType,
}

---@param mode string
---@return string
local function formatModes(mode)
	return _formatModes[mode] or mode
end

---@param mode string
---@return string
local function formatVolumeType(mode)
	return volumeType[mode] or ""
end

function SettingsTab:Audio(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local iris = configs.iris
	local a = settings.audio
	local g = settings.gameplay

	just.text(Text.volume)
	just.next(0, textSeparation)

	a.volumeType =
		imgui.combo("a.volumeType", a.volumeType, { "linear", "logarithmic" }, formatVolumeType, Text.volumeType)

	local v = a.volume
	if a.volumeType == "linear" then
		v.master = imgui.slider1("v.master", v.master * 100, "%i%%", 0, 100, 1, Text.master) / 100
		v.music = imgui.slider1("v.music", v.music * 100, "%i%%", 0, 100, 1, Text.music) / 100
		v.effects = imgui.slider1("v.effects", v.effects * 100, "%i%%", 0, 100, 1, Text.effects) / 100
		v.metronome = imgui.slider1("v.metronome", v.metronome * 100, "%i%%", 0, 100, 1, Text.metronome) / 100
		iris.uiVolume = imgui.slider1("iris.uiVolume", iris.uiVolume * 100, "%i%%", 0, 100, 1, Text.uiVolume) / 100
	elseif a.volumeType == "logarithmic" then
		v.master = imgui.lfslider("v.master", v.master, "%ddB", -60, 0, 1, Text.master)
		v.music = imgui.lfslider("v.music", v.music, "%ddB", -60, 0, 1, Text.music)
		v.effects = imgui.lfslider("v.effects", v.effects, "%ddB", -60, 0, 1, Text.effects)
		v.metronome = imgui.lfslider("v.metronome", v.metronome, "%ddB", -60, 0, 1, Text.metronome)
		iris.uiVolume = imgui.lfslider("iris.uiVolume", iris.uiVolume, "%ddB", -60, 0, 1, Text.uiVolume)
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
	[1] = Text.enabled,
	[0] = Text.disabled,
	[-1] = Text.adaptive,
}

local fullscreenType = {
	["desktop"] = Text.desktop,
	["exclusive"] = Text.exclusive,
}

local cursor = {
	["circle"] = Text.circle,
	["arrow"] = Text.arrow,
	["system"] = Text.system,
}

---@param v number?
---@return string
local function formatVsync(v)
	return vsyncNames[v] or ""
end

---@param v number?
---@return string
local function formatFullscreenType(v)
	return fullscreenType[v] or ""
end

---@param v number?
---@return string
local function formatCursor(v)
	return cursor[v] or ""
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

function SettingsTab:Keybinds(view)
	imgui.separator()
	local settings = view.game.configModel.configs.settings
	local i = settings.input

	just.text(Text.gameplay)
	just.next(0, textSeparation)
	i.skipIntro = imgui.hotkey("skipIntro", i.skipIntro, Text.skipIntro)
	i.quickRestart = imgui.hotkey("quickRestart", i.quickRestart, Text.quickRestart)

	imgui.separator()
	just.text(Text.uiTab)
	just.next(0, textSeparation)
	i.selectRandom = imgui.hotkey("selectRandom", i.selectRandom, Text.selectRandom)
	i.screenshot.capture = imgui.hotkey("screenshot.capture", i.screenshot.capture, Text.captureScreenshot)
	i.screenshot.open = imgui.hotkey("screenshot.open", i.screenshot.open, Text.openScreenshot)

	imgui.separator()
	just.text(Text.offset)
	just.next(0, textSeparation)
	i.offset.decrease = imgui.hotkey("offset.decrease", i.offset.decrease, Text.decrease)
	i.offset.increase = imgui.hotkey("offset.increase", i.offset.increase, Text.increase)

	imgui.separator()
	just.text(Text.scrollSpeed)
	just.next(0, textSeparation)
	i.playSpeed.decrease = imgui.hotkey("playSpeed.decrease", i.playSpeed.decrease, Text.decrease)
	i.playSpeed.increase = imgui.hotkey("playSpeed.increase", i.playSpeed.increase, Text.increase)

	imgui.separator()
	just.text(Text.timeRate)
	just.next(0, textSeparation)
	i.timeRate.decrease = imgui.hotkey("timeRate.decrease", i.timeRate.decrease, Text.decrease)
	i.timeRate.increase = imgui.hotkey("timeRate.increase", i.timeRate.increase, Text.increase)
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
end

---@param f table
---@return string
local function filter_to_string(f)
	return f.name
end

function SettingsTab:UI(view)
	imgui.separator()
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local s = configs.select
	local g = settings.graphics
	local iris = configs.iris

	just.text(Text.uiTab)
	just.next(0, textSeparation)
	g.cursor = imgui.combo("g.cursor", g.cursor, { "circle", "arrow", "system" }, formatCursor, Text.cursor)
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

	imgui.separator()
	just.text(Text.select)
	just.next(0, textSeparation)
	s.collapse = imgui.checkbox("s.collapse", s.collapse, Text.groupCharts)

	local filters = view.game.configModel.configs.filters.notechart
	local config = view.game.configModel.configs.select
	local i = imgui.SpoilerList("NotechartFilterDropdown", 400, 50, filters, config.filterName, filter_to_string)
	if i then
		config.filterName = filters[i].name
		view.game.selectModel:noDebouncePullNoteChartSet()
	end

	local sortFunction = view.game.configModel.configs.select.sortFunction
	local sortModel = view.game.selectModel.sortModel

	just.next(0, textSeparation)

	local a = imgui.SpoilerList("SortDropdown", 400, 50, sortModel.names, sortFunction)
	local name = sortModel.names[a]
	if name then
		view.game.selectModel:setSortFunction(name)
	end

	just.next(0, textSeparation)
	local m = settings.miscellaneous
	m.showNonManiaCharts = imgui.checkbox("showNonManiaCharts", m.showNonManiaCharts, Text.showNonManiaCharts)

	iris.startSound = imgui.combo("iris.startSound", iris.startSound, Theme.sounds.startSoundNames, nil, "START SOUND !!!")
end

function SettingsTab:Version(view)
	imgui.separator()
	local settings = view.game.configModel.configs.settings
	local m = settings.miscellaneous
	just.next(0, textSeparation)
	m.autoUpdate = imgui.checkbox("autoUpdate", m.autoUpdate, Text.autoUpdate)

	imgui.separator()
	just.text(Text.themeVersion .. Theme.version)
	just.text(Text.commit .. version.commit)
	just.text(Text.commitDate .. version.date)
end

return SettingsTab
