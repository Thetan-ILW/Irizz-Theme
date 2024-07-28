local l = {}

l.textGroups = {
	songSelect = {
		mappedBy = "Mapped by %s",
		from = "From %s",
		chartInfoFirstRow = "Length: %s BPM: %s Objects: %s",
		chartInfoSecondRow = "Circles: %s Sliders: %s Spinners: %s",
		chartInfoThirdRow = "Keys: %s OD: %s HP: %s Star rating: %s",
		--
		localRanking = "Local ranking",
		onlineRankin = "Online ranking",
		osuApiRanking = "osu! API ranking",
		--
		collections = "Collections",
		recent = "Recent",
		artist = "Artist",
		difficulty = "Difficulty",
		noGrouping = "No grouping",
		--
		group = "Group",
		sort = "Sort",
		byCharts = "By Charts",
		byLocations = "By Locations",
		byDirectories = "By Directories",
		byId = "By ID",
		byTitle = "By Title",
		byArtist = "By Artist",
		byDifficulty = "By Difficulty",
		byLevel = "By Level",
		byLength = "By Length",
		byBpm = "By BPM",
		byModTime = "By Mod. time",
		bySetModTime = "By Set Mod. time",
		byLastPlayed = "By Last played",
		--
		search = "Search:",
		searchInsert = "Search (Insert):",
		typeToSearch = "Type to search!",
		noMatches = "No matches found.",
		matchesFound = "%i match(es) found.",
	},
	scoreList = {
		score = "Score",
		hasMods = "Has mods",
	},
	chartOptionsModal = {
		manageLocations = "1. Manage locations",
		chartInfo = "2. Chart info",
		filters = "3. Filters",
		edit = "4. Edit",
		fileManager = "5. Open in file manager",
		cancel = "6. Cancel",
	},
	result = {
		chartBy = "Chart by %s",
		chartFrom = "Chart from %s",
		playedBy = "Played by %s on %s",
		mean = "Mean: %s",
		maxError = "Max error: %s",
		scrollSpeed = "Scroll speed: %s",
		mods = "Mods: %s",
		guest = "Guest",
	},
}

l.fontFiles = {
	["ZenMaruGothic-Black"] = "irizz/fonts/ZenMaruGothic/ZenMaruGothic-Black.ttf",
	["ZenMaruGothic-Medium"] = "irizz/fonts/ZenMaruGothic/ZenMaruGothic-Medium.ttf",
	["ZenMaruGothic-Bold"] = "irizz/fonts/ZenMaruGothic/ZenMaruGothic-Bold.ttf",
	["ZenMaruGothic-Regular"] = "irizz/fonts/ZenMaruGothic/ZenMaruGothic-Regular.ttf",
	["Aller"] = "resources/osu_default_assets/ui_font/Aller_Rg.ttf",
	["Aller-Light"] = "resources/osu_default_assets/ui_font/Aller_Lt.ttf",
	["Aller-Bold"] = "resources/osu_default_assets/ui_font/Aller_Bd.ttf",
}

l.fontGroups = {
	songSelect = {
		chartName = { "Aller", 25, "ZenMaruGothic-Medium" },
		chartedBy = { "Aller", 16, "ZenMaruGothic-Medium" },
		infoTop = { "Aller-Bold", 16 },
		infoCenter = { "Aller", 16 },
		infoBottom = { "Aller", 12 },
		dropdown = { "Aller", 19 },
		groupSort = { "Aller-Light", 30 },
		username = { "Aller", 20, "ZenMaruGothic-Medium" },
		belowUsername = { "Aller", 14 },
		rank = { "Aller-Light", 50 },
		scrollSpeed = { "Aller-Light", 23 },
		tabs = { "Aller", 14 },
		mods = { "Aller", 41 },
		search = { "Aller-Bold", 18, "ZenMaruGothic-Bold" },
		searchMatches = { "Aller-Bold", 15 },
	},
	chartSetList = {
		title = { "Aller", 22, "ZenMaruGothic-Medium" },
		secondRow = { "Aller", 16, "ZenMaruGothic-Medium" },
		thirdRow = { "Aller-Bold", 16, "ZenMaruGothic-Medium" },
		noItems = { "Aller", 36 },
	},
	scoreList = {
		username = { "Aller-Bold", 22, "ZenMaruGothic-Medium" },
		score = { "Aller", 16 },
		rightSide = { "Aller", 14 },
		noItems = { "Aller", 36 },
	},
	chartOptionsModal = {
		title = { "Aller-Light", 33 },
		buttons = { "Aller", 42 },
	},
	resultView = {
		title = { "ZenMaruGothic-Black", 36 },
		creator = { "ZenMaruGothic-Regular", 24 },
		playInfo = { "ZenMaruGothic-Regular", 24 },
		accuracy = { "ZenMaruGothic-Regular", 20 },
		graphInfo = { "ZenMaruGothic-Regular", 18 },
		pp = { "ZenMaruGothic-Medium", 36 },
	},
}

return l
