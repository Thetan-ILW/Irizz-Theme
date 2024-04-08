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

ColorTheme.colors = {
	-- COLORS
	accent = Hex("#30c5c9"), -- Light teal (stars)
	darkerAccent = Hex("#0a5f69"), -- Dark teal (deep sky)
	headerSelect = Hex("#52a8a9"), -- Medium teal (highlighted constellation)
	-- TEXT
	text = Hex("#D3D3D3"), -- Light gray (clouds)
	textShadow = { 0.1, 0.1, 0.1, 0.7 }, -- Dark shadow for contrast
	unfocusedText = { 0.5, 0.5, 0.5, 1 }, -- Gray for unfocused text
	darkText = { 0.1, 0.1, 0.1, 1 }, -- Dark gray for text on light backgrounds
	-- PANELS
	panel = Hex("#11111199"), -- Transparent dark gray (night sky)
	border = Hex("#4F4F4F"), -- Dark gray for borders
	-- LINES AND RECTANGLES IN PANELS
	separator = Hex("#373737"), -- Lighter dark gray for separators
	innerPanel = Hex("#00000077"), -- Transparent black for inner panels
	-- LISTS
	itemDownloaded = { 1, 1, 1, 0.5 }, -- Transparent white for downloaded items
	listItemOdd = { 0, 0, 0, 0 }, -- Transparent black for odd list items
	listItemEven = { 0.2, 0.2, 0.2, 0.15 }, -- Transparent dark gray for even list items
	-- UI
	select = Hex("#30c5c955"), -- Transparent light teal for selection
	button = { 0, 0, 0, 0 }, -- Transparent for buttons
	buttonHover = { 1, 1, 1, 0.2 }, -- Transparent white for button hover
	uiFrames = { 1, 1, 1, 0.8 }, -- Transparent light gray for UI frames
	uiPanel = { 0.1, 0.1, 0.1, 0.7 }, -- Transparent dark gray for UI panels
	uiHover = { 0.2, 0.2, 0.2, 0.7 }, -- Transparent darker gray for UI hover
	uiActive = { 0.2, 0.2, 0.2, 0.9 }, -- Transparent darkest gray for UI active
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
