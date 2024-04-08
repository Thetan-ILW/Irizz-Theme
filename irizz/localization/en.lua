local localization = {}

localization.name = "English"

localization.textHeader = {
	settings = "Settings",
	songs = "Songs",
	collections = "Collections",
	notLoggedIn = "Offline",
	online = "Online: %i",
}

localization.textSettings = {
	gameplayTab = "Gameplay",
	audioTab = "Audio",
	videoTab = "Video",
	timingsTab = "Timings",
	keybindsTab = "Keybinds",
	inputsTab = "Inputs",
	uiTab = "UI",
	versionTab = "Version",
	--
	scrollSpeed = "Scroll speed",
	speedType = "Speed type",
	actionOnFail = "Action on fail",
	actionNone = "None",
	actionPause = "Pause",
	actionQuit = "Quit",
	scaleScrollSpeed = "Scale scroll speed with rate",
	lnShortening = "LN shortening",
	tempoFactor = "Tempo factor",
	primaryTempo = "Primary tempo",
	lastMeanValues = "Last mean values",
	taikoSV = "Taiko SV",
	hp = "Gauge/HP",
	hpShift = "Auto shift",
	hpNotes = "Max health",
	waitTime = "Wait time (in seconds)",
	prepare = "Prepare",
	playPause = "Play->Pause",
	pausePlay = "Pause->Play",
	playRetry = "Play->Retry",
	pauseRetry = "Pause->Retry",
	--
	ratingHitWindow = "Rating hit window",
	inputOffest = "Input offset",
	visualOffset = "Visual offset",
	multiplyInputOffset = "Multiply input offset by time rate",
	multiplyVisualOffset = "Multiply visual offset by time rate",
	--
	volumeType = "Volume type",
	linearType = "Linear",
	logarithmicType = "Logarithmic",
	master = "Master",
	music = "Music",
	effects = "Effects",
	metronome = "Metronome",
	uiVolume = "UI",
	audioPitch = "Time rate changes pitch",
	autoKeySound = "Auto key sound",
	adjustRate = "Timer adjust rate",
	midiConstantVolume = "MIDI constant volume",
	latency = "Latency: ",
	updatePeriod = "Update period",
	bufferLength = "Buffer length",
	apply = "Apply",
	reset = "Reset",
	--
	fpsLimit = "FPS limit",
	fullscreen = "Fullscreen",
	fullscreenType = "Fullscreen type",
	vsync = "Vsync",
	vsyncOnSelect = "Vsync in Song Select Screen",
	dwmFlush = "DWM flush",
	threadedInput = "Threaded input",
	startupWindowResolution = "Window resolution at startup",
	cursor = "Cursor",
	backgroundAnimation = "Background animation",
	video = "Video",
	image = "Image",
	camera = "Camera",
	enableCamera = "Enable camera",
	allowRotateX = "Allow rotation of X coordinate",
	allowRotateY = "Allow rotation of Y coordinate",
	--
	offset = "Offset",
	timeRate = "Time rate",
	pause = "Pause",
	none = "None",
	quit = "Quit",
	skipIntro = "Skip intro",
	quickRestart = "Restart",
	increase = "Increase",
	decrease = "Decrease",
	selectRandom = "Select random",
	captureScreenshot = "Capture screenshot",
	openScreenshot = "Open screenshot",
	--
	dim = "Dim",
	blur = "Blur",
	showOnlineCount = "Show online players count",
	showSpectrum = "Show spectrum analyzer",
	backgroundEffects = "Background effects",
	panelBlur = "Blur under panels",
	ch_ab = "Chromatic aberration",
	distortion = "Distortion",
	spectrum = "Spectrum analyzer color",
	solidColor = "Solid color",
	invertedColor = "Inverted color",
	select = "Song Select",
	collections = "Collections",
	gameplay = "Gameplay",
	result = "Result",
	groupCharts = "Group charts",
	rateType = "Time rate type",
	linear = "Linear",
	exp = "Exp",
	colorTheme = "Color theme",
	vimMotions = "Vim motions (RESTART REQUIRED)",
	scrollAcceleration = "Scroll acceleration",
	scrollClickExtraTime = "Scroll click extra time",
	--
	themeVersion = "Theme version: ",
	commit = "Commit: ",
	commitDate = "Date: ",
	--
	scoring = "Scoring",
	scoreSystem = "Score system",
	judgement = "Judgement",
	nearest = "Closest note scoring",
	noteHitWindow = "Note hit window",
	noteMissWindow = "Note miss window",
	lnHitWindow = "LN hit window",
	lnMissWindow = "LN miss window",
	early = " (Early)",
	late = " (Late)",
	releaseHitWindow = "Release hit window",
	releaseMissWindow = "Release miss window",
	--
	default = "Default",
	osu = "osu!",
	average = "Average",
	primary = "Primary",
	minimum = "Minimum",
	maximum = "Maximum",
	desktop = "Desktop",
	exclusive = "Exclusive",
	enabled = "Enabled",
	disabled = "Disabled",
	adaptive = "Adaptive",
	circle = "Circle",
	arrow = "Arrow",
	system = "System",
	other = "Other",
	volume = "Volume",
	audioDevice = "Audio device",
	bpm = "%i BPM",
	noMods = "No modifiers",
	const = "Constant scroll speed",
	singleNoteHandler = "Taiko note handler",
	muteOnUnfocus = "Mute game out of focus",
	autoUpdate = "Auto update",
	showNonManiaCharts = "Show non-mania charts",
	difficulty = "Difficulty",
	sort = "Sort",
	startSound = "Start sound",
	staticCursor = "Static cursor in lists",
	showLocations = "Show locations",
	chartFormatOffsets = "Offsets for chart formats",
	audioModeOffsets = "Offsets for audio modes",
	chartLengthBeforeArtist = "Show chart length in chart list",
}

localization.textSongSelect = {
	noCharts = "No charts!",
	noChartSets = "No chart sets!",
	noScores = "No scores!",
	length = "%s LENGTH",
	notes = "%s NOTES",
	bpm = "%i BPM",
	ln = "%i%% LN",
	searchPlaceholder = "Type to search...",
	filterPlaceholder = "No filters.",
	noMods = "No mods",
	hasMods = "Has mods",
	score = "Score: %i",
	noPatterns = "No patterns",
}

localization.textCollections = {
	queueEmpty = "Queue is empty!",
	notInOsuDirect = "Not in osu!direct mode!",
	noCollections = "No collections!",
	cache = "Cache",
	collections = "Collections",
	osuDirect = "osu!direct",
	mounts = "Mounts",
	searching = "Status: Searching for charts: %d",
	creatingCache = "Status: Creating the cache: %0.2f%%",
	download = "Download",
	redownload = "Redownload",
	wait = "Wait...",
	osuDirectSearchPlaceholder = "Type to search...",
}

localization.textModifiers = {
	modifiers = "Modifiers",
}

localization.textNoteSkins = {
	noteSkins = "Note skins",
	noSettings = "No settings!",
}

localization.textInputs = {
	inputs = "Inputs",
	noInputs = "No chart selected.\nCannot determine input mode.",
}

localization.textMounts = {
	mounts = "Mounts",
	noMounts = "No mounts!",
	update = "Update",
	deleteCache = "Delete cache",
	processingCharts = "Processing charts...",
	path = "Path",
	chartsFound = "Processed / Found",
	chartsCached = "Charts cached",
	create = "Create",
	delete = "Delete",
}

localization.textOnline = {
	notLoggedIn = "Connect to the server:",
	loggedIn = "You are connected to the server.",
	connect = "Sign in",
	quickConnect = "Login with browser",
	logout = "Log out",
	emailPlaceholder = "Email",
	passwordPlaceholder = "Password",
}

localization.textFilters = {
	filters = "Filters",
	moddedCharts = "Show modified charts",
	chartCount = "%i charts in '%s'",
	charts = "Charts",
	scores = "Scores",
	scoresSource = "Source of scores",
	inputMode = "Mode",
	actualInputMode = "Exact mode",
	format = "Format",
	scratch = "Scratch",
	played = "Played",
}

localization.textResult = {
	score = "SCORE",
	accuracy = "ACCURACY",
	inputMode = "INPUT MODE",
	timeRate = "TIME RATE",
	pauses = "PAUSES",
	scrollSpeed = "SCROLL SPEED",
	noPatterns = "No patterns",
	noAccuracy = "No accuracy",
}

localization.textMultiplayer = {
	title = "Multiplayer and players",
	noPlayers = "Nobody is online.",
	players = "Players:",
	noRooms = "No rooms.\nCreate one and invite your friends!",
	createTip = "Create your own room:",
	createRoom = "Create a room",
	playing = "Playing",
	join = "Join",
	name = "Name",
	password = "Password",
	create = "Create",
	enterPassword = "Enter password to join the %s",
	back = "Back",
	notConnected = "Trying to connect.\nStatus: %s",
	room = "Room: %s",
	host = "Host: %s",
}

localization.textMultiplayerScreen = {
	roomName = "Room name: %s",
	playerCount = "Players: %i",
}

localization.textChartInfo = {
	chartInfo = "Chart info",
	artist = "Artist",
	title = "Title",
	chartName = "Name",
	bpm = "BPM",
	tags = "Tags",
	source = "Source",
	chartFormat = "Format",
	setName = "Set name",
	path = "Path",
	audioPath = "Audio path",
	backgroundPath = "Background path",
	mode = "Mode",
	chartFileName = "Chart file name",
	hash = "MD5 hash",
}

localization.textKeybinds = {
	keybindsFor = "Key binds for: %s",
	select = "song select",
	result = "result screen",
}

localization.keybindsGlobal = {
	insertMode = "Insert mode",
	normalMode = "Normal mode",
	quit = "Close a window or quit from a screen",
	showChartInfo = "Show all information about the selected chart",
	showKeybinds = "Show keybind table (You are here)",
}

localization.keybindsLargeList = {
	up = "Move up in the list",
	down = "Move down in the list",
	up10 = "Move up 10 items in the list",
	down10 = "Move down 10 items in the list",
	toStart = "Move to the start of the list",
	toEnd = "Move to the end of the list",
}

localization.keybindsSmallList = {
	up = "Move up in the small list",
	down = "Move down in the small list",
}

localization.keybindsSongSelect = {
	play = "Play the selected chart",
	showMods = "Show song modifications",
	random = "Randomize the chart selection",
	decreaseTimeRate = "Decrease the music time rate",
	increaseTimeRate = "Increase the music time rate",
	undoRandom = "Undo the random chart selection",
	clearSearch = "Clear the search field",
	moveScreenLeft = "Move the screen to the left",
	moveScreenRight = "Move the screen to the right",
	pauseMusic = "Pause the music",
	showSkins = "Show available skins",
	showFilters = "Show chart and score filters",
	showInputs = "Show input settings",
	showMultiplayer = "Show multiplayer window or return to lobby",
	autoPlay = "Start chart in auto-play mode",
	openEditor = "Open the chart editor",
}

localization.keybindsResult = {
	watchReplay = "Watch the replay",
	retry = "Retry the chart",
	submitScore = "(Re)submit your score",
}

localization.fontFamilyList = {
	["Noto Sans"] = {
		"resources/fonts/NotoSansCJK-Regular.ttc",
		"resources/fonts/NotoSans-Minimal.ttf",
		height = 813 / 758,
	},
	["Noto Sans Mono"] = {
		"resources/fonts/NotoSansMono-Regular.ttf",
		"resources/fonts/NotoSansMono-Minimal.ttf",
		height = 730 / 699,
	},
	["ZenMaruGothic-Black"] = {
		"irizz/fonts/ZenMaruGothic/ZenMaruGothic-Black.ttf",
	},
	["ZenMaruGothic-Medium"] = {
		"irizz/fonts/ZenMaruGothic/ZenMaruGothic-Medium.ttf",
	},
}

localization.fonts = {
	header = {
		anyText = { "ZenMaruGothic-Black", 24 },
	},

	settingsViewConfig = {
		tabs = { "ZenMaruGothic-Medium", 28 },
	},

	songSelectViewConfig = {
		searchField = { "ZenMaruGothic-Black", 36 },
		filterLine = { "ZenMaruGothic-Black", 24 },
		difficulty = { "ZenMaruGothic-Medium", 28 },
		calculator = { "ZenMaruGothic-Medium", 24 },
		patterns = { "ZenMaruGothic-Medium", 22 },
		info = { "ZenMaruGothic-Medium", 28 },
		moreInfo = { "ZenMaruGothic-Medium", 28 },
		timeRate = { "ZenMaruGothic-Medium", 32 },
		mods = { "ZenMaruGothic-Medium", 24 },
		titleAndDifficulty = { "ZenMaruGothic-Black", 32 },
	},

	collectionsViewConfig = {
		searchField = { "ZenMaruGothic-Black", 36 },
		queue = { "ZenMaruGothic-Medium", 32 },
		osuDirectCharts = { "ZenMaruGothic-Medium", 32 },
		buttons = { "ZenMaruGothic-Medium", 28 },
		titleAndMode = { "ZenMaruGothic-Black", 32 },
	},

	noteChartListView = {
		inputMode = { "ZenMaruGothic-Black", 18 },
		difficulty = { "ZenMaruGothic-Black", 24 },
		creator = { "ZenMaruGothic-Black", 18 },
		name = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	noteChartSetListView = {
		artist = { "ZenMaruGothic-Black", 18 },
		title = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	collectionsListView = {
		itemCount = { "ZenMaruGothic-Black", 18 },
		name = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	scoreListView = {
		line1 = { "ZenMaruGothic-Black", 20 },
		line2 = { "ZenMaruGothic-Black", 18 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	osuDirectListView = {
		artist = { "ZenMaruGothic-Black", 18 },
		title = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	osuDirectChartsListView = {
		creator = { "ZenMaruGothic-Black", 18 },
		difficultyName = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	osuDirectQueueListView = {
		title = { "ZenMaruGothic-Black", 24 },
		artist = { "ZenMaruGothic-Black", 14 },
		status = { "ZenMaruGothic-Black", 14 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	modifiersModal = {
		title = { "ZenMaruGothic-Black", 72 },
		modifierName = { "ZenMaruGothic-Black", 24 },
		inputMode = { "ZenMaruGothic-Black", 48 },
		numberOfUses = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	noteSkinModal = {
		title = { "ZenMaruGothic-Black", 72 },
		skinName = { "ZenMaruGothic-Black", 48 },
		noteSkinName = { "ZenMaruGothic-Black", 24 },
		noteSkinSettings = { "ZenMaruGothic-Black", 24 },
		noSettings = { "ZenMaruGothic-Medium", 36 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	inputsModal = {
		title = { "ZenMaruGothic-Black", 72 },
		tabs = { "ZenMaruGothic-Medium", 28 },
		noInputs = { "ZenMaruGothic-Medium", 36 },
		inputs = { "ZenMaruGothic-Black", 24 },
		inputMode = { "ZenMaruGothic-Black", 48 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	mountsModal = {
		title = { "ZenMaruGothic-Black", 72 },
		tabs = { "ZenMaruGothic-Medium", 28 },
		noItems = { "ZenMaruGothic-Medium", 36 },
		mountPaths = { "ZenMaruGothic-Black", 24 },
		windowText = { "ZenMaruGothic-Black", 24 },
		fields = { "ZenMaruGothic-Medium", 28 },
		path = { "ZenMaruGothic-Black", 48 },
		status = { "ZenMaruGothic-Medium", 36 },
		buttons = { "ZenMaruGothic-Medium", 18 },
	},

	onlineModal = {
		status = { "ZenMaruGothic-Black", 48 },
		fields = { "ZenMaruGothic-Medium", 36 },
		buttons = { "ZenMaruGothic-Medium", 28 },
	},

	filtersModal = {
		title = { "ZenMaruGothic-Black", 72 },
		checkboxes = { "ZenMaruGothic-Black", 24 },
		headerText = { "ZenMaruGothic-Black", 28 },
		filtersLine = { "ZenMaruGothic-Black", 48 },
	},

	multiplayerModal = {
		title = { "ZenMaruGothic-Black", 72 },
		listHeader = { "ZenMaruGothic-Black", 32 },
		lists = { "ZenMaruGothic-Black", 24 },
		buttons = { "ZenMaruGothic-Black", 28 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	resultView = {
		titleAndDifficulty = { "ZenMaruGothic-Black", 32 },
		hitError = { "ZenMaruGothic-Medium", 16 },
		judgements = { "ZenMaruGothic-Medium", 24 },
		accuracy = { "ZenMaruGothic-Medium", 28 },
		scoreInfo = { "ZenMaruGothic-Medium", 30 },
		pauses = { "ZenMaruGothic-Medium", 24 },
		difficulty = { "ZenMaruGothic-Medium", 28 },
		calculator = { "ZenMaruGothic-Medium", 24 },
		patterns = { "ZenMaruGothic-Medium", 22 },
		modifiers = { "ZenMaruGothic-Black", 48 },
	},

	multiplayerView = {
		titleAndDifficulty = { "ZenMaruGothic-Black", 32 },
		roomInfo = { "ZenMaruGothic-Black", 24 },
	},

	keybindsModal = {
		title = { "ZenMaruGothic-Black", 72 },
		keybinds = { "ZenMaruGothic-Black", 18 },
	},

	chartInfoModal = {
		title = { "ZenMaruGothic-Black", 72 },
		info = { "ZenMaruGothic-Black", 24 },
	},
}

return localization
