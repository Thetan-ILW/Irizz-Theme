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
	accent = Hex("#29b673"), -- Forest Green
	darkerAccent = Hex("#19794e"), -- Darker Green
	headerSelect = Hex("#90e0cc"), -- Light Blue

	-- TEXT
	text = Hex("#000000"), -- Black
	textShadow = Hex("#aaaaaa"),
	unfocusedText = Hex("#222222"),
	darkText = { 0.2, 0.2, 0.2, 1 },

	-- PANELS
	panel = Hex("#f2f2f2aa"), -- Light Gray with transparency
	border = Hex("#cccccc"), -- Light Gray

	-- LINES AND RECTANGLES IN PANELS
	separator = Hex("#dddddd"), -- Lighter Gray
	innerPanel = Hex("#e0e0e0aa"), -- Light Gray with transparency

	-- LISTS
	itemDownloaded = { 1, 1, 1, 0.5 },
	listItemOdd = { 0.9, 0.9, 0.9, 0.15 }, -- Very Light Gray
	listItemEven = { 0.85, 0.85, 0.85, 0.15 }, -- Lighter Gray

	-- UI
	select = Hex("#29b67355"), -- Transparent Forest Green
	button = { 0, 0, 0, 0.1 }, -- Very transparent black
	buttonHover = { 1, 1, 1, 0.2 },
	uiFrames = { 1, 1, 1, 0.8 },
	uiPanel = { 0.9, 0.9, 0.9, 0.7 }, -- Light Gray
	uiHover = { 0.85, 0.85, 0.85, 0.7 }, -- Lighter Gray
	uiActive = { 0.8, 0.8, 0.8, 0.9 }, -- Even Lighter Gray
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
