local localization = require("irizz.localization.en")
local gfx_util = require("gfx_util")

local ModifierEncoder = require("sphere.models.ModifierEncoder")
local ModifierModel = require("sphere.models.ModifierModel")

local function Hex(rgba)
	local rb = tonumber(string.sub(rgba, 2, 3), 16)
	local gb = tonumber(string.sub(rgba, 4, 5), 16)
	local bb = tonumber(string.sub(rgba, 6, 7), 16)
	local ab = tonumber(string.sub(rgba, 8, 9), 16) or 255
	local r, g, b, a = love.math.colorFromBytes(rb, gb, bb, ab)
	return { r, g, b, a }
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local Theme = {}

Theme.sounds = {
	startSounds = {},
	startSoundNames = {},
	scrollSoundLargeList = love.audio.newSource("irizz/sounds/hitsound_retro3.wav", "static"),
	scrollSoundSmallList = love.audio.newSource("irizz/sounds/hitsound_retro5.wav", "static"),
}

Theme.fontFamilyList = {}

Theme.colors = {
	panel = Hex("#000000AA"),
	border = Hex("#FFFFFF"),
	mutedBorder = Hex("#616161"),
	headerButtonBackground = {0, 0, 0, 0.2},
	transparentPanel = Hex("#00000077"),
	accent = Hex("#fc72e3"),
	darkerAccent = Hex("#bf58ca"),
	select = Hex("#f669db55"),
	headerSelect = Hex("#ff8cfa"),
	text = Hex("#FFFFFF"),
	textShadow = {0.3, 0.3, 0.3, 0.7},
	unfocusedText = { 0.75, 0.75, 0.75, 1 },
	darkText = { 0.2, 0.2, 0.2, 1 },
	itemDownloaded = { 1, 1, 1, 0.5 },
	listItemOdd = { 0, 0, 0, 0 },
	listItemEven = { 0.5, 0.5, 0.5, 0.15 },
	button = { 0, 0, 0, 0 },
	buttonHover = { 1, 1, 1, 0.2 },
	uiFrames = { 1, 1, 1, 0.8 },
	uiPanel = { 0.1, 0.1, 0.1, 0.7 },
	uiHover = { 0.2, 0.2, 0.2, 0.7 },
	uiActive = { 0.2, 0.2, 0.2, 0.9 },
	hitPerfect = { 0.25, 0.95, 1, 1 },
	hitBad = { 1, 0.92, 0.25, 1 },
	hitVeryBad = { 0, 0.86, 0.18, 1 },
	hitMiss = { 1, 0, 0, 1 },
	spectrum = Hex("#fc72e3"),
}

Theme.layout = {
	outerPanelsSize = 350,
	innerPanelSize = 400,
	gap = 20,
	verticalPanelGap = 30,
	horizontalPanelGap = 30,
	settingsTabsPanelSize = 250,
	settingsMainPanelSize = 800,
	collectionsOuterPanelsSize = 350,
	collectionInnerPanelSize = 400,
	collectionsVerticalPanelGap = 30,
	collectionsButtonsPanelScale = 0.7,
}

Theme.imgui = {
	size = 50,
	rounding = 10,
	nextItemOffset = 10,
}

Theme.misc = {
	staticListViewCursor = true,
}

for k, v in pairs(localization) do
	Theme[k] = v
end

local difficultyColors = {
	{ 0.25, 0.79, 0.90, 1 },
	{ 0.24, 0.78, 0.17, 1 },
	{ 0.89, 0.78, 0.22, 1 },
	{ 0.91, 0.15, 0.32, 1 },
	{ 0.97, 0.20, 0.26, 1 },
	{ 0.90, 0.15, 0.91, 1 },
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local difficultyRanges = {
	enps_diff = {
		{ 0,  6 },
		{ 6,  10 },
		{ 10, 14 },
		{ 14, 19 },
		{ 19, 23 },
		{ 23, 32 },
	},
	msd_diff = {
		{ 0,  8 },
		{ 8,  15 },
		{ 15, 20 },
		{ 20, 25 },
		{ 25, 29 },
		{ 29, 32 },
	},
	user_diff = {
		{ 0,  6 },
		{ 6,  8 },
		{ 8,  12 },
		{ 12, 17 },
		{ 17, 19 },
		{ 19, 23 },
	},
	osu_diff = {
		{ 0, 2 },
		{ 2, 3.5 },
		{ 3.5, 5.3 },
		{ 5.3, 6.2 },
		{ 6.2, 8 },
		{ 8, 10 }
	}
}

---@param difficulty number
---@param calculatorName string
---@return table
function Theme:getDifficultyColor(difficulty, calculatorName)
	local ranges = difficultyRanges[calculatorName]
	if not ranges then
		error("Invalid calculator name: " .. calculatorName)
	end

	local colorIndex = 1
	for i = #ranges, 1, -1 do
		local range = ranges[i]
		if difficulty >= range[1] then
			colorIndex = i
			break
		end
	end

	local lowerLimit, upperLimit
	if colorIndex == 1 then
		lowerLimit = 0
		upperLimit = ranges[1][2]
	elseif colorIndex == #difficultyColors then
		return difficultyColors[#difficultyColors]
	else
		lowerLimit, upperLimit = ranges[colorIndex][1], ranges[colorIndex][2]
	end

	local color1, color2 = difficultyColors[colorIndex], difficultyColors[colorIndex + 1]

	local mixingRatio = (difficulty - lowerLimit) / (upperLimit - lowerLimit)

	return {
		color1[1] * (1 - mixingRatio) + color2[1] * mixingRatio,
		color1[2] * (1 - mixingRatio) + color2[2] * mixingRatio,
		color1[3] * (1 - mixingRatio) + color2[3] * mixingRatio,
		1,
	}
end

---@param list table?
---@return string?
local function getFirstFile(list)
	if not list then
		return
	end
	for _, path in ipairs(list) do
		if love.filesystem.getInfo(path) then
			return path
		end
	end
end

local instances = {}

---@param filename string
---@param size number
---@return love.Font
local function getFont(filename, size)
	if instances[filename] and instances[filename][size] then
		return instances[filename][size]
	end
	local f = Theme.fontFamilyList[filename]

	local font = love.graphics.newFont(getFirstFile(f) or filename, size)
	instances[filename] = instances[filename] or {}
	instances[filename][size] = font
	if f and f.height then
		font:setLineHeight(f.height)
	end
	return font
end

---@nodiscard
function Theme:getFonts(objectName)
	local fonts = self.fonts[objectName]
	local loadedFonts = {}

	for key, font in pairs(fonts) do
		loadedFonts[key] = getFont(font[1], font[2])
	end

	return loadedFonts
end

local hitColors = {
	Hex("#99ccff"),
	Hex("#f2cb30"),
	Hex("#14cc8f"),
	Hex("#1ab2ff"),
	Hex("#ff1ab3"),
}

local missColor = Hex("#cc2929")

function Theme:getHitColor(delta, isMiss)
	if isMiss then
		return missColor
	end

	delta = math.abs(delta)

	if delta < 0.016 then
		return hitColors[1]
	elseif delta < 0.037 then
		return hitColors[2]
	elseif delta < 0.07 then
		return hitColors[3]
	elseif delta < 0.1 then
		return hitColors[4]
	else
		return hitColors[5]
	end
end

---@param mods table
---@return string
function Theme:getModifierString(mods)
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

	if modString == "" then
		modString = "No mods"
	end

	return modString
end

function Theme:setLines()
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(4)
end

function Theme:panel(w, h)
	love.graphics.setColor(self.colors.panel)
	love.graphics.rectangle("fill", 0, 0, w, h, 8, 8)
end

local lineWidth = 4
local half = lineWidth / 2
function Theme:border(w, h)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(lineWidth)
	love.graphics.setColor(self.colors.border)
	love.graphics.rectangle("line", -half, -half, w + lineWidth, h + lineWidth, 8, 8)
end

local shadowOffset = 3
function Theme:textWithShadow(text, w, h, ax, ay)
	local r, g, b, a  = love.graphics.getColor()
	love.graphics.setColor(self.colors.textShadow)
	gfx_util.printFrame(text, shadowOffset, shadowOffset, w, h, ax, ay)
	love.graphics.setColor({r, g, b, a})
	gfx_util.printFrame(text, 0, 0, w, h, ax, ay)
end

function Theme:init()
	local startSoundNames = love.filesystem.getDirectoryItems("irizz/sounds/start")

	local t = {}

	for _, name in ipairs(startSoundNames) do
		t[name] = love.audio.newSource("irizz/sounds/start/" .. name, "static")
	end

	self.sounds.startSounds = t
	self.sounds.startSoundNames = startSoundNames

	local avatarPath = "userdata/avatar.png"
	local gameIconPath = "userdata/game_icon.png"

	if love.filesystem.getInfo(avatarPath) then
		self.avatarImage = love.graphics.newImage(avatarPath)
	else
		self.avatarImage = love.graphics.newImage("irizz/avatar.png")
	end

	if love.filesystem.getInfo(gameIconPath) then
		self.gameIcon = love.graphics.newImage(gameIconPath)
	else
		self.gameIcon = love.graphics.newImage("irizz/game_icon.png")
	end

end

function Theme:getStartSound(game)
	local config = game.configModel.configs.irizz
	return self.sounds.startSounds[config.startSound]
end

local diff_columns_names = {
	enps_diff = "ENPS",
	osu_diff = "OSU",
	msd_diff = "MSD",
	user_diff = "USER",
}

---@param v number?
---@return string
function Theme.formatDiffColumns(v)
	return diff_columns_names[v] or ""
end

local filterAliasses = {
	["(not) played"] = Theme.textFilters.played,
	["actual input mode"] = Theme.textFilters.actualInputMode,
	["original input mode"] = Theme.textFilters.inputMode,
	format = Theme.textFilters.format,
	scratch = Theme.textFilters.scratch,
}

function Theme.formatFilter(v)
	return filterAliasses[v] or v
end

local scoreSystems = {
	"soundsphere",
	"etterna",
	"osu",
}

local judges = {
	etterna = {4, 5, 6, 7},
	osu = {5, 6, 7, 8, 9, 10}
}

local judgePrefix = {
	etterna = "J",
	osu = "OD"
}

function Theme.getScoreSystems()
	return scoreSystems
end

function Theme.getJudges(name)
	return judges[name]
end

function Theme.getPrefix(name)
	return judgePrefix[name] or ""
end

return Theme
