local ColorTheme = {}

local function Hex(rgba)
	local rb = tonumber(string.sub(rgba, 2, 3), 16)
	local gb = tonumber(string.sub(rgba, 4, 5), 16)
	local bb = tonumber(string.sub(rgba, 6, 7), 16)
	local ab = tonumber(string.sub(rgba, 8, 9), 16) or 255
	local r, g, b, a = love.math.colorFromBytes(rb, gb, bb, ab)
	return { r, g, b, a }
end

-- You can use either tables of 4 values (R, G, B, A), or use the Hex funttion
-- Good luck with creating a color theme, even I don't understand what the hell is happening here and in the internal code

ColorTheme.ui = {
	-- COLORS
	accent = Hex("#fc72e3"),
	darkerAccent = Hex("#bf58ca"),
	headerSelect = Hex("#ff8cfa"),
	-- TEXT
	text = Hex("#FFFFFF"),
	textShadow = { 0.3, 0.3, 0.3, 0.7 },
	unfocusedText = { 0.75, 0.75, 0.75, 1 },
	darkText = { 0.2, 0.2, 0.2, 1 },
	-- PANELS
	panel = Hex("#00000099"),
	border = Hex("#FFFFFF"),
	-- LINES AND RECTANGLES IN PANELS
	separator = Hex("#616161"),
	innerPanel = Hex("#00000077"),
	-- LISTS
	itemDownloaded = { 1, 1, 1, 0.5 },
	listItemOdd = { 0, 0, 0, 0 },
	listItemEven = { 0.5, 0.5, 0.5, 0.15 },
	-- UI
	select = Hex("#f669db55"),
	button = { 0, 0, 0, 0 },
	buttonHover = { 1, 1, 1, 0.2 },
	uiFrames = { 1, 1, 1, 0.8 },
	uiPanel = { 0.1, 0.1, 0.1, 0.7 },
	uiHover = { 0.2, 0.2, 0.2, 0.7 },
	uiActive = { 0.2, 0.2, 0.2, 0.9 },
}

ColorTheme.difficultyColors = {
	{ 0.25, 0.79, 0.90, 1 }, -- Easy (aqua)
	{ 0.24, 0.78, 0.17, 1 }, -- Normal (green)
	{ 0.89, 0.78, 0.22, 1 }, -- Hard (yellow)
	{ 0.91, 0.15, 0.32, 1 }, -- Instane (red)
	{ 0.97, 0.20, 0.26, 1 }, -- Expert (pink)
	{ 0.90, 0.15, 0.91, 1 }, -- Very Expert (very pink)
}

ColorTheme.difficultyRanges = {
	enps_diff = {
		{ 0, 6 },
		{ 6, 10 },
		{ 10, 14 },
		{ 14, 19 },
		{ 19, 23 },
		{ 23, 32 },
	},
	msd_diff = {
		{ 0, 8 },
		{ 8, 15 },
		{ 15, 23 },
		{ 23, 29 },
		{ 29, 32 },
		{ 32, 36 },
	},
	user_diff = {
		{ 0, 6 },
		{ 6, 8 },
		{ 8, 12 },
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
		{ 8, 10 },
	},
}

ColorTheme.hitColors = {
	Hex("#99ccff"),
	Hex("#f2cb30"),
	Hex("#14cc8f"),
	Hex("#1ab2ff"),
	Hex("#ff1ab3"),
}

ColorTheme.missColor = Hex("#cc2929")

return ColorTheme
