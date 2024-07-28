local assets = require("thetan.skibidi.assets")

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

---@param v string?
---@return string
function Theme.formatDiffColumns(v)
	return diff_columns_names[v] or ""
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
