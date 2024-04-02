local assets = require("thetan.irizz.assets")
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

return Theme
