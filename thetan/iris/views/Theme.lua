local localization = require("iris.localization.en")

local function Hex(rgba)
	local rb = tonumber(string.sub(rgba, 2, 3), 16)
	local gb = tonumber(string.sub(rgba, 4, 5), 16)
	local bb = tonumber(string.sub(rgba, 6, 7), 16)
	local ab = tonumber(string.sub(rgba, 8, 9), 16) or 255
	local r, g, b, a = love.math.colorFromBytes( rb, gb, bb, ab )
	return {r, g, b, a}
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local Theme = {}

Theme.sounds = {
	ui = 0.2,
	scrollSoundLargeList = love.audio.newSource("iris/sounds/hitsound_retro3.wav", "static"),
	scrollSoundSmallList = love.audio.newSource("iris/sounds/hitsound_retro5.wav", "static")
}

Theme.fontFamilyList = {}

Theme.colors = {
	panel = Hex("#000000AA"),
    border = Hex("#adadad"),
	mutedBorder = Hex("#616161"),
	transparentPanel = Hex("#00000077"),
	accent = Hex("#fc72e3"),
	darkerAccent = Hex("#bf58ca"),
	select = Hex("#f669db55"),
	headerSelect = Hex("#e97bf6"),
	text = Hex("#FFFFFF"),
	darkText = {0.2, 0.2, 0.2, 1},
	itemDownloaded = {1, 1, 1, 0.5},
	listItemOdd = {0, 0, 0, 0},
	listItemEven = {0.5, 0.5, 0.5, 0.15},
	button = {0, 0, 0, 0},
	buttonHover = {1, 1, 1, 0.2},
	uiFrames = {1, 1, 1, 0.8},
	uiPanel = {0.1, 0.1, 0.1, 0.7},
	uiHover = {0.2, 0.2, 0.2, 0.7},
	uiActive = {0.2, 0.2, 0.2, 0.9}
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
	staticListViewCursor = true
}

for k, v in pairs(localization) do
	Theme[k] = v
end

local difficultyColors = {
	{0.25, 0.79, 0.90, 1},
	{0.24, 0.78, 0.17, 1},
	{0.89, 0.78, 0.22, 1},
	{0.91, 0.15, 0.32, 1},
	{0.97, 0.20, 0.26, 1},
	{0.90, 0.15, 0.91, 1}
}

local msdColorRanges = {
	{0, 8},
	{8, 15},
	{15, 20},
	{20, 25},
	{25, 29},
	{29, 32},
}

local enpsColorRanges = {
	{0, 6},
	{6, 10},
	{10, 14},
	{14, 19},
	{19, 23},
	{23, 32},
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

---@param difficulty number
---@param calculator string
---@return table
function Theme:getDifficultyColor(difficulty, calculator)
	if difficulty > 32 then
		return difficultyColors[#difficultyColors]
	elseif difficulty < 5 then
		return difficultyColors[1]
	end

	local colorRanges = calculator == "msd" and msdColorRanges or enpsColorRanges

	local colorIndex
	for i, range in pairs(colorRanges) do
		if difficulty >= range[1] and difficulty <= range[2] then
			colorIndex = i
			break
		end
	end

	if (colorIndex == 1) then
		colorIndex = 2
	end

	local lowerLimit, upperLimit = colorRanges[colorIndex][1], colorRanges[colorIndex][2]

	local color1 = difficultyColors[colorIndex - 1]
	local color2 = difficultyColors[colorIndex]
	
	local mixingRatio = (difficulty - lowerLimit) / (upperLimit - lowerLimit)

	local mixedColor = {
		color1[1] * (1 - mixingRatio) + color2[1] * mixingRatio,
		color1[2] * (1 - mixingRatio) + color2[2] * mixingRatio,
		color1[3] * (1 - mixingRatio) + color2[3] * mixingRatio,
		1
	}

	return mixedColor
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

Theme.version = "0.1.0"

return Theme