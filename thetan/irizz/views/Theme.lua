local assets = require("thetan.skibidi.assets")
local gfx_util = require("gfx_util")
local math_util = require("math_util")
local has_minacalc, etterna_msd = pcall(require, "libchart.libchart.etterna_msd")

if has_minacalc then
	if etterna_msd.getVersion then
		assert(etterna_msd.getVersion() == "0.1.2", "Update to the latest MinaCalc version.")
	else
		assert(false, "Update to the latest MinaCalc version.")
	end
end

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

---@param objectName string
---@param scale number?
---@return table<string, love.Font>
---@nodiscard
function Theme:getFonts(objectName, scale)
	scale = scale or 1
	local fonts = self.fonts[objectName]
	local loadedFonts = {}

	for key, font in pairs(fonts) do
		loadedFonts[key] = assets:getFont(self.fontFamilyList, font[1], font[2] * scale)
		loadedFonts[key]:setFilter("nearest", "nearest")

		if font[3] then
			loadedFonts[key]:setFallbacks(assets:getFont(self.fontFamilyList, font[3], font[2] * scale))
		end
	end

	return loadedFonts
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

function Theme:changeVolume(game, direction)
	local configs = game.configModel.configs
	local settings = configs.settings
	local a = settings.audio
	local v = a.volume

	v.master = math_util.clamp(v.master + (direction * 0.05), 0, 1)

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
		if item.setVolume then
			item:setVolume(volume)
		else -- table
			for _, sound in pairs(item) do
				if not sound.setVolume then
					break
				end

				sound:setVolume(volume)
			end
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

function Theme.getMaxAndSecondFromMsd(msd)
	local maxValue = 0
	local secondValue = 0
	local maxKey = nil
	local secondKey = nil

	for key, value in pairs(msd) do
		value = tonumber(value)
		if value > maxValue and key ~= "overall" then
			maxValue = value
			maxKey = key
		end
	end

	local threshold = maxValue * 0.93
	for key, value in pairs(msd) do
		value = tonumber(value)
		if value < maxValue and value >= threshold and value > secondValue and key ~= "overall" then
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

function Theme.getFirstFromMsd(msd)
	local maxKey = nil
	local maxValue = 0
	for key, value in pairs(msd) do
		value = tonumber(value)
		if value > maxValue and key ~= "overall" then
			maxValue = value
			maxKey = key
		end
	end

	return maxKey
end

function Theme.simplifySsr(pattern)
	if pattern == "stream" then
		return "STR"
	elseif pattern == "jumpstream" then
		return "JS"
	elseif pattern == "handstream" then
		return "HS"
	elseif pattern == "stamina" then
		return "STAM"
	elseif pattern == "jackspeed" then
		return "JACK"
	elseif pattern == "chordjack" then
		return "CJ"
	elseif pattern == "technical" then
		return "TECH"
	end

	return "NONE"
end

function Theme.getMsdPatterns(msd_data)
	if type(etterna_msd) ~= "table" then
		return nil
	end

	local ssr = etterna_msd:decode(msd_data)
	return ssr
end

function Theme.getSsrPatternNames()
	return etterna_msd.orderedSsr
end

function Theme.getMsdFromData(msd_data, time_rate)
	if not has_minacalc then
		return nil
	end

	local msds = etterna_msd:decode(msd_data)

	if msds then
		return etterna_msd.getApproximate(msds, time_rate)
	end
end

local filterAliasses = {
	["(not) played"] = "played",
	["actual input mode"] = "actualInputMode",
	["original input mode"] = "inputMode",
	format = "format",
	scratch = "scratch",
}

function Theme.formatFilter(v)
	return Theme.textFilters[filterAliasses[v]] or v
end

local function getStrainMultiplier(s)
	if s < 500000 then
		return s / 500000 * 0.1
	elseif s < 600000 then
		return (s - 500000) / 100000 * 0.3
	elseif s < 700000 then
		return (s - 600000) / 100000 * 0.25 + 0.3
	elseif s < 800000 then
		return (s - 700000) / 100000 * 0.2 + 0.55
	elseif s < 900000 then
		return (s - 800000) / 100000 * 0.15 + 0.75
	else
		return (s - 900000) / 100000 * 0.1 + 0.9
	end
end

-- SOURCE: maniapp.uy.to
function Theme.getPP(notes, star_rate, od, score)
	local strain = math.pow(5 * math.max(1, star_rate / 0.2) - 4, 2.2) / 135 * (1 + 0.1 * math.min(1, notes / 1500))
	local strain_multiplier = getStrainMultiplier(score)

	local accuracy_value = 0

	if score >= 960000 then
		accuracy_value = od * 0.02 * strain * math.pow((score - 960000) / 40000, 1.1)
	end

	return (0.73 * math.pow(math.pow(accuracy_value, 1.1) + math.pow(strain * strain_multiplier, 1.1), 1 / 1.1) * 1.1)
end

return Theme
