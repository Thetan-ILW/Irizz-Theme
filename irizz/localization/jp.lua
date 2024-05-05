local localization = {}

localization.language = "日本語"

localization.textHeader = {
	settings = "設定",
	songs = "曲",
	collections = "コレクション",
	notLoggedIn = "オフライン",
	online = "オンライン: %i",
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
	logarithmic = "Logarithmic",
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
	solid = "Solid color",
	inverted = "Inverted color",
	select = "Song Select",
	collections = "Collections",
	gameplay = "Gameplay",
	result = "Result",
	groupCharts = "Group charts",
	alwaysShowOriginalMode = "Always show original input mode",
	rateType = "Time rate type",
	linear = "Linear",
	exp = "Exp",
	language = "Language (RESTART REQUIRED)",
	colorTheme = "Color theme",
	vimMotions = "Vim motions",
	scrollAcceleration = "Scroll acceleration",
	scrollClickExtraTime = "Scroll click extra time",
	transitionAnimation = "Transition animation",
	fade = "Fade",
	shutter = "Shutter",
	--
	osuResultScreen = "osu! result screen",
	enable = "Enable",
	showHpGraph = "Show HP graph",
	showPP = "Show PP",
	skin = "Skin",
	--
	commit = "Commit: ",
	commitDate = "Date: ",
	contributors = "Big thanks to contributors:",
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
	startSound = "Start sound",
	staticCursor = "Static cursor in lists",
	showLocations = "Show locations",
	chartFormatOffsets = "Offsets for chart formats",
	audioModeOffsets = "Offsets for audio modes",
	chartLengthBeforeArtist = "Show chart length in chart list",
}

localization.textSongSelect = {
	length = "%s 長さ",
	notes = "%s ノーツ",
	bpm = "%i BPM",
	ln = "%i%% LN",
	searchPlaceholder = "検索するには入力してください...",
	filterPlaceholder = "フィルターなし。",
	score = "スコア: %i",
	noPatterns = "パターン無し",
}

localization.textCollections = {
	cache = "キャッシュ",
	collections = "コレクション",
	osuDirect = "osu!direct",
	mounts = "マウント",
	searching = "ステータス: チャートを検索中: %d",
	creatingCache = "ステータス: キャッシュを作成中: %0.2f%%",
	download = "ダウンロード",
	redownload = "再ダウンロード",
	wait = "少しお待ちください...",
	osuDirectSearchPlaceholder = "検索するには入力してください...",
}

localization.textScoreList = {
	noItems = "スコアがありません！",
	noMods = "Modなし",
	hasMods = "Modあり",
}

localization.textChartList = {
	noItems = "チャートがありません！",
}

localization.textChartSetsList = {
	noItems = "チャートセットがありません！",
}

localization.textQueueList = {
	noItems = "キューは空です！",
}

localization.textOsuDirectList = {
	noItems = "osu!directモードではありません！",
}

localization.textCollectionsList = {
	noItems = "コレクションがありません！",
}

localization.textModifiersList = {
	noItems = "No selected mods!",
}

localization.textAvailableModifiersList = {
	noItems = "Your game is broken if you see this.",
}

localization.textModifiers = {
	modifiers = "修飾子",
}

localization.textInputsList = {
	noItems = "譜面が選択されていません。\n入力モードを決定できません。",
}

localization.textNoteSkinsList = {
	noItems = "No note skins.",
}

localization.textRoomsList = {
	noItems = "ルームがありません。\n自分で作成して友達を招待しましょう！",
	playing = "プレイ中",
	join = "参加",
	room = "ルーム: %s",
	host = "ホスト: %s",
}

localization.textMountsList = {
	noItems = "マウントがありません！",
}

localization.textNoteSkins = {
	noteSkins = "ノートスキン",
	noSettings = "設定がありません！",
}

localization.textInputs = {
	inputs = "入力",
}

localization.textMounts = {
	mounts = "マウント",
	update = "アップデート",
	deleteCache = "キャッシュを削除",
	processingCharts = "譜面を処理中...",
	path = "パス",
	chartsFound = "処理済み / 見つかりました",
	chartsCached = "譜面をキャッシュされました",
	create = "作る",
	delete = "削除",
	locations = "場所",
	database = "データベース",
	chartdiffs = "譜面の難易度 / レーティング",
	chartmetas = "譜面のメタデータ",
	compute = "計算",
	computed = "計算済み: %i",
}

localization.textOnline = {
	notLoggedIn = "サーバーに接続:",
	loggedIn = "サーバーに接続しました。",
	connect = "サインイン",
	quickConnect = "ブラウザでログイン",
	logout = "ログアウト",
	emailPlaceholder = "メール",
	passwordPlaceholder = "パスワード",
}

localization.textOsuApi = {
	loading = "Loading...",
	noScores = "No scores!",
	wait = "Wait...",
	noToken = "No access token.",
	noId = "No beatmap ID",
}

localization.textFilters = {
	filters = "フィルター",
	moddedCharts = "修正されたチャートを表示",
	chartCount = "%i 譜面 in '%s'",
	charts = "譜面",
	scores = "スコア",
	scoresSource = "スコアのソース",
	inputMode = "キーモード",
	actualInputMode = "実際のモード",
	format = "フォーマット",
	scratch = "スクラッチ",
	played = "プレイ済み",
}

localization.textResult = {
	timeRate = "Time rate: %0.02fx",
	pauses = "Pauses:",
	grade = "Grade:",
	scrollSpeed = "Scroll speed:",
	hitWindow = "Hit window",
	missWindow = "Miss window",
	releaseMultiplier = "Release multiplier",
	hitLogic = "Hit logic",
	nearest = "Nearest",
	earliestNote = "Earliest note",
	noPatterns = "No patterns",
	mode = "Mode: ",
	score = "Score: ",
	accuracy = "Accuracy: ",
	rating = "Rating: ",
	mean = "Mean: ",
	maxError = "Max error: ",
}

localization.textOsuResult = {
	chartBy = "Chart by %s",
	chartFrom = "Chart from %s",
	playedBy = "Played by %s on %s",
	mean = "Mean: %s",
	maxError = "Max error: %s",
	scrollSpeed = "Scroll speed: %s",
	mods = "Mods: %s",
	guest = "Guest",
}

localization.textMultiplayer = {
	title = "マルチプレイヤーとプレイヤー",
	noPlayers = "オンラインの人はいません。",
	players = "プレイヤー:",
	createTip = "自分のルームを作る:",
	createRoom = "ルームを作る",
	name = "名",
	password = "パスワード",
	create = "作る",
	enterPassword = "%sのパスワードを入れてください",
	back = "戻る",
	notConnected = "接続を試みています。\nステータス: %s",
}

localization.textMultiplayerScreen = {
	roomName = "ルーム名: %s",
	playerCount = "プレイヤー: %i",
}

localization.textChartInfo = {
	chartInfo = "譜面情報",
	artist = "アーティスト",
	title = "タイトル",
	chartName = "名",
	bpm = "BPM",
	tags = "タグ",
	source = "ソース",
	chartFormat = "フォーマット",
	setName = "セット名",
	path = "パス",
	audioPath = "オーディオパス",
	backgroundPath = "バックパス",
	mode = "モード",
	chartFileName = "譜面ファイル名",
	hash = "MD5ハッシュ",
}

localization.textMainMenu = {
	morning = "Good morning!",
	day = "Good day!",
	evening = "Good evening!",
	night = "Good night!",
	modifiers = "Modifiers",
	filters = "Filters",
	noteSkins = "Note skins",
	inputs = "Inputs",
	keyBinds = "Key binds",
	multiplayer = "Multiplayer",
	chartEditor = "Chart editor",
}

localization.textKeybinds = {
	keybinds = "キーコンフィグ",
}

localization.fontFamilyList = {
	["ZenMaruGothic-Black"] = {
		"irizz/fonts/ZenMaruGothic/ZenMaruGothic-Black.ttf",
	},
	["ZenMaruGothic-Medium"] = {
		"irizz/fonts/ZenMaruGothic/ZenMaruGothic-Medium.ttf",
	},
	["Titillium-Web-Regular"] = {
		"irizz/fonts/Titillium_Web/TitilliumWeb-Regular.ttf",
	},
	["Titillium-Web-SemiBold"] = {
		"irizz/fonts/Titillium_Web/TitilliumWeb-SemiBold.ttf",
	},
	["Titillium-Web-Bold"] = {
		"irizz/fonts/Titillium_Web/TitilliumWeb-Bold.ttf",
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
		textHeader = { "ZenMaruGothic-Medium", 28 },
		mountPaths = { "ZenMaruGothic-Black", 24 },
		windowText = { "ZenMaruGothic-Medium", 24 },
		fields = { "ZenMaruGothic-Medium", 28 },
		path = { "ZenMaruGothic-Black", 48 },
		status = { "ZenMaruGothic-Medium", 36 },
		buttons = { "ZenMaruGothic-Medium", 28 },
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
		modifiers = { "ZenMaruGothic-Medium", 28 },
		accuracy = { "ZenMaruGothic-Medium", 28 },
		counterName = { "ZenMaruGothic-Medium", 24 },
		grade = { "ZenMaruGothic-Regular", 24 },
		timings = { "ZenMaruGothic-Regular", 24 },
		difficultyValue = { "ZenMaruGothic-Medium", 32 },
		calculator = { "ZenMaruGothic-Medium", 24 },
		patterns = { "ZenMaruGothic-Regular", 24 },
		timeRate = { "ZenMaruGothic-Medium", 32 },
		scoreInfo = { "ZenMaruGothic-Regular", 24 },
	},

	osuResultView = {
		title = { "ZenMaruGothic-Black", 36 },
		creator = { "Titillium-Web-Regular", 24 },
		playInfo = { "Titillium-Web-Regular", 24 },
		accuracy = { "Titillium-Web-Regular", 20 },
		graphInfo = { "Titillium-Web-Regular", 18 },
		pp = { "Titillium-Web-SemiBold", 36 },
	},

	multiplayerView = {
		titleAndDifficulty = { "ZenMaruGothic-Black", 32 },
		roomInfo = { "ZenMaruGothic-Black", 24 },
	},

	keybindsModal = {
		title = { "ZenMaruGothic-Black", 72 },
		keybinds = { "ZenMaruGothic-Black", 24 },
	},

	chartInfoModal = {
		title = { "ZenMaruGothic-Black", 72 },
		info = { "ZenMaruGothic-Medium", 24 },
	},

	notifications = {
		message = { "ZenMaruGothic-Medium", 36 },
		smallText = { "ZenMaruGothic-Medium", 24 },
	},

	mainMenuView = {
		title = { "ZenMaruGothic-Medium", 72 },
		timeOfDay = { "ZenMaruGothic-Medium", 48 },
		buttons = { "ZenMaruGothic-Medium", 24 },
	},
}

return localization
