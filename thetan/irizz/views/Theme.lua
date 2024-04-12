local assets = require("thetan.irizz.assets")
local etterna_ssr = require("libchart.libchart.etterna_ssr")
local gfx_util = require("gfx_util")

local ModifierEncoder = require("sphere.models.ModifierEncoder")
local ModifierModel = require("sphere.models.ModifierModel")

local Theme = {}

Theme.colors = {}
Theme.colorThemes = {}

Theme.sounds = {
	start = {},
	startNames = {},
}

Theme.fontFamilyList = {}

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

Theme.actions = {}

assets:init(Theme)

---@param difficulty number
---@param calculatorName string
---@return table
function Theme:getDifficultyColor(difficulty, calculatorName)
	local difficultyRanges = self.difficultyRanges
	local difficultyColors = self.difficultyColors

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

---@nodiscard
function Theme:getFonts(objectName)
	local fonts = self.fonts[objectName]
	local loadedFonts = {}

	for key, font in pairs(fonts) do
		loadedFonts[key] = assets:getFont(self.fontFamilyList, font[1], font[2])
	end

	return loadedFonts
end

function Theme:getHitColor(delta, isMiss)
	if isMiss then
		return self.missColor
	end

	local hitColors = self.hitColors
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
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(self.colors.textShadow)
	gfx_util.printFrame(text, shadowOffset, shadowOffset, w, h, ax, ay)
	love.graphics.setColor({ r, g, b, a })
	gfx_util.printFrame(text, 0, 0, w, h, ax, ay)
end

function Theme:init(game)
	local configs = game.configModel.configs
	assets:get(configs.irizz, self)
	self:updateVolume(game)
end

function Theme:updateVolume(game)
	local configs = game.configModel.configs
	local settings = configs.settings
	local irizz = configs.irizz
	local a = settings.audio
	local v = a.volume

	local volume = irizz.uiVolume * v.master
	for _, item in pairs(self.sounds) do
		if type(item) == "table" then
			for _, sound in pairs(item) do
				if not sound.setVolume then
					break
				end

				sound:setVolume(volume)
			end
		else
			item:setVolume(volume)
		end
	end
end

function Theme:playSound(name)
	local sound = self.sounds[name]

	if not sound then
		return
	end

	sound:stop()
	sound:play()
end

function Theme:getStartSound(game)
	local config = game.configModel.configs.irizz
	return self.sounds.start[config.startSound]
end

local diff_columns_names = {
	enps_diff = "ENPS",
	osu_diff = "OSU",
	msd_diff = "MSD",
	user_diff = "USER",
}

---@param v string?
---@return string
function Theme.formatDiffColumns(v)
	return diff_columns_names[v] or ""
end

function Theme.getMaxAndSecondFromSsr(ssrStr)
	local ssr = etterna_ssr:decodePatterns(ssrStr)

	local maxValue = 0
	local secondValue = 0
	local maxKey = nil
	local secondKey = nil

	for key, value in pairs(ssr) do
		value = tonumber(value)
		if value > maxValue then
			maxValue = value
			maxKey = key
		end
	end

	local threshold = maxValue * 0.93
	for key, value in pairs(ssr) do
		value = tonumber(value)
		if value < maxValue and value >= threshold and value > secondValue then
			secondValue = tonumber(value)
			secondKey = key
		end
	end

	local output = maxKey
	if secondKey then
		output = output .. "\n" .. secondKey
	end

	return output
end

function Theme.getPatterns(ssrStr)
	local ssr = etterna_ssr:decodePatterns(ssrStr)
	return ssr
end

local startRate = 5
local endRate = 20

local rates = {
	[5] = -9.596700450446,
	[6] = -7.5957415414244,
	[7] = -5.6011114260133,
	[8] = -3.6665763668184,
	[9] = -1.8159235652606,
	[10] = 0,
	[11] = 1.8084870281745,
	[12] = 3.5579764407329,
	[13] = 5.226905998569,
	[14] = 6.7957089410407,
	[15] = 8.242713109125,
	[16] = 9.518206709407,
	[17] = 10.62611215231,
	[18] = 11.578847354464,
	[19] = 12.382336869914,
	[20] = 13.073366502886,
}

local patternWeight = {
	stream = 1.04,
	jumpstream = 1.035,
	handstream = 1,
	stamina = 1,
	jackspeed = 1.04,
	chordjack = 1.072,
	technical = 1,
}

local function interpolate(x1, y1, x2, y2, x)
	return y1 + (x - x1) * (y2 - y1) / (x2 - x1)
end

function Theme.getApproximate(overall, patterns, timeRate)
	local index = math.floor(timeRate * 10)
	local fraction = (timeRate * 10) - index

	local ssr = etterna_ssr:decodePatterns(patterns)
	local maxValue = 0
	local maxKey = nil

	for key, value in pairs(ssr) do
		value = tonumber(value)
		if value > maxValue then
			maxValue = value
			maxKey = key
		end
	end

	local additional = patternWeight[maxKey]
	local approximate = 0

	if index < startRate then
		approximate = rates[startRate]
	elseif index >= endRate then
		approximate = rates[endRate]
	elseif fraction == 0 then
		approximate = rates[index]
	else
		local x1 = index / 10
		local y1 = rates[index]
		local x2 = (index + 1) / 10
		local y2 = rates[index + 1]
		approximate = interpolate(x1, y1, x2, y2, timeRate)
	end

	return (overall + approximate) * additional
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

return Theme
