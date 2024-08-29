local l = {}

l.textGroups = {
	mainMenu = {
		chartCount = "You have %i charts available!",
		sessionTime = "Game has been running for %s",
		time = "It is currently %s",
	},
	settings = {
		-------------- Graphics
		graphics = "GRAPHICS",
		-- Renderer
		renderer = "RENDERER",
		vsyncType = "Vsync type:",
		fpsLimit = "FPS limit:",
		showFPS = "Show FPS",
		vsyncInSongSelect = "Vsync in Song Select",
		adaptive = "Adaptive",
		enabled = "Enabled",
		disabled = "Disabled",
		-- Layout
		layout = "LAYOUT",
		fullscreenType = "Fullscreen type:",
		windowResolution = "Window resolution:",
		desktop = "Desktop",
		exclusive = "Exclusive",
		fullscreen = "Fullscreen",
		-- Details
		details = "DETAIL SETTINGS",
		backgroundVideos = "Background videos",
		backgroundImages = "Background images",
		-------------- Audio
		audio = "AUDIO",
		-- Volume
		volume = "VOLUME",
		master = "Master:",
		music = "Music:",
		effect = "Effect:",
		rateChangesPitch = "Rate changes pitch",
		autoKeySound = "Auto key sound",
		midiConstantVolume = "MIDI constant volume",
		muteOnUnfocus = "Minimized game mutes music",
		-- Device
		device = "DEVICE",
		updatePeriod = "Update period",
		bufferLength = "Buffer length",
		adjustRate = "Adjust rate",
		apply = "Apply",
		reset = "Reset",
	},
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
		byDuration = "By Duration",
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
	uiLock = {
		processingCharts = "Processing charts...",
		path = "Path",
		chartsFound = "Processed / Found",
		chartsCached = "Charts cached",
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
	mainMenu = {
		username = { "Aller", 20, "ZenMaruGothic-Regular" },
		belowUsername = { "Aller", 14 },
		info = { "Aller", 18, "ZenMaruGothic-Regular" },
	},
	settings = {
		optionsLabel = { "Aller-Light", 28, "ZenMaruGothic-Regular" },
		gameBehaviorLabel = { "Aller-Light", 19, "ZenMaruGothic-Regular" },
		search = { "Aller", 25, "ZenMaruGothic-Regular" },
		tabLabel = { "Aller", 33, "ZenMaruGothic-Regular" },
		groupLabel = { "Aller-Bold", 16, "ZenMaruGothic-Regular" },
		buttons = { "Aller", 16, "ZenMaruGothic-Regular" },
		checkboxes = { "Aller", 16, "ZenMaruGothic-Regular" },
		combos = { "Aller", 16, "ZenMaruGothic-Regular" },
		sliders = { "Aller", 16, "ZenMaruGothic-Regular" },
		version = { "Aller", 16, "ZenMaruGothic-Regular" },
	},
	songSelect = {
		chartName = { "Aller", 25, "ZenMaruGothic-Regular" },
		chartedBy = { "Aller", 16, "ZenMaruGothic-Regular" },
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
	result = {
		title = { "Aller-Light", 30, "ZenMaruGothic-Regular" },
		creator = { "Aller", 22 },
		playInfo = { "Aller", 22 },
		graphInfo = { "ZenMaruGothic-Regular", 18 },
		pp = { "ZenMaruGothic-Medium", 36 },
	},
	uiLock = {
		title = { "Aller-Bold", 48 },
		status = { "Aller", 36 },
	},
}

return l
