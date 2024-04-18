local localization = {}

localization.language = "Русский"

localization.textHeader = {
	settings = "Настройки",
	songs = "Песни",
	collections = "Коллекции",
	notLoggedIn = "Не в сети",
	online = "В сети: %i",
}

localization.textSettings = {
	gameplayTab = "Gameplay",
	audioTab = "Аудио",
	videoTab = "Видео",
	timingsTab = "Timings",
	keybindsTab = "Keybinds",
	inputsTab = "Inputs",
	uiTab = "UI",
	versionTab = "Version",
	--
	scrollSpeed = "Скорость прокрутки",
	speedType = "Тип скорости",
	actionOnFail = "Действие при смерти",
	actionNone = "Ничего",
	actionPause = "Пауза",
	actionQuit = "Выход",
	scaleScrollSpeed = "Скалировать скорость прокрутки с рейтом",
	lnShortening = "Короткие длинные ноты",
	tempoFactor = "Тип темпа",
	primaryTempo = "Первичный темп?",
	lastMeanValues = "Последние средние значения",
	taikoSV = "Тайко прокрутка",
	hp = "Здоровье",
	hpShift = "Автоматическое смещение",
	hpNotes = "Максимальное здоровье",
	waitTime = "Время ожидания (в секундах)",
	prepare = "Подготовка",
	playPause = "Игра->Пауза",
	pausePlay = "Пауза->Игра",
	playRetry = "Игра->Перезапуск",
	pauseRetry = "Пауза->Перезапуск",
	--
	ratingHitWindow = "Rating hit window",
	inputOffest = "Сдвиг ввода",
	visualOffset = "Визуальный сдвиг",
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
	offset = "Сдвиг",
	timeRate = "Time rate",
	pause = "Пауза",
	none = "Ничего",
	quit = "Выход",
	skipIntro = "Пропустить интро",
	quickRestart = "Перезапуск",
	increase = "Увеличить",
	decrease = "Уменьшить",
	selectRandom = "Выбрать случайное",
	captureScreenshot = "Сделать скриншот",
	openScreenshot = "Открыть скриншот",
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
	length = "%s ДЛИНА",
	notes = "%s НОТЫ",
	bpm = "%i УВМ", -- может лучше BPM оставить? ни один русский не знает что такое УВМ на самом деле
	ln = "%i%% ДЛ. НОТЫ",
	searchPlaceholder = "Нажмите чтобы найти...", -- Тут скорее лучше 'Пишите' или 'Напишите'. Но всё равно как то не так
	filterPlaceholder = "Нет фильтров.",
	score = "Рекорд: %i",
	noPatterns = "Нет паттернов",
}

localization.textCollections = {
	cache = "Кэш",
	collections = "Коллекции",
	osuDirect = "osu!direct",
	mounts = "Ручная установка",
	searching = "Статус: поиск карт: %d",
	creatingCache = "Статус: создания кэша: %0.2f%%",
	download = "Загрузить",
	redownload = "Перезагрузить",
	wait = "Подождите...",
	osuDirectSearchPlaceholder = "Нажмите чтобы найти...",
}

localization.textChartList = {
	noItems = "Нет карт!",
}

localization.textChartSetsList = {
	noItems = "Нет набора карт!",
}

localization.textScoreList = {
	noItems = "Нет рекордов!",
	noMods = "Нет модов",
	hasMods = "Есть моды",
}

localization.textQueueList = {
	noItems = "Очередь пуста!",
}

localization.textOsuDirectList = {
	noItems = "Не в osu!direct режиме!",
}

localization.textCollectionsList = {
	noItems = "Нет коллекций!",
}

localization.textModifiersList = {
	noItems = "No selected mods!",
}

localization.textAvailableModifiersList = {
	noItems = "Your game is broken if you see this.",
}

localization.textInputsList = {
	noItems = "Карта не выбрана.\nНе удается определить режим ввода.",
}

localization.textNoteSkinsList = {
	noItems = "Нет скинов!",
}

localization.textRoomsList = {
	noItems = "Нет комнат.\nСоздайте свою и пригласите своих друзей!",
	playing = "Playing",
	join = "Присоедениться",
	room = "Комната: %s",
	host = "Хост: %s",
}

localization.textMountsList = {
	noItems = "Нет привязок!", -- я не знаю как это назвать. Хрен эти маунты на русский язык ты переведешь.
}

localization.textModifiers = {
	modifiers = "Модификаторы",
}

localization.textNoteSkins = {
	noteSkins = "Скины",
	noSettings = "Нет настроек!",
}

localization.textInputs = {
	inputs = "Привязка клавиш",
}

localization.textMounts = {
	mounts = "Ручная установка",
	update = "Обновить",
	deleteCache = "Удалить кэш",
	processingCharts = "Обработка карт...",
	path = "Путь",
	chartsFound = "Обработано / Найдено",
	chartsCached = "Кэшированные карты ",
	create = "Создать",
	delete = "Удалить",
	locations = "Местоположение",
	database = "База данных",
	chartdiffs = "Сложность карты",
	chartmetas = "Метаданные карты",
	compute = "Подсчитать",
	computed = "Подсчитанно: %i",
}

localization.textOnline = {
	notLoggedIn = "Подключится к серверу:",
	loggedIn = "Вы подключены к серверу.",
	connect = "Войти",
	quickConnect = "Войти с помощью бразуера",
	logout = "Выйти",
	emailPlaceholder = "Эл.почта",
	passwordPlaceholder = "Пароль",
}

localization.textFilters = {
	filters = "Фильтры",
	moddedCharts = "Показывать модифицированные карты",
	chartCount = "%i карт в '%s'",
	charts = "Карты",
	scores = "Рекорды",
	scoresSource = "Источник рекордов",
	inputMode = "Режим",
	actualInputMode = "Точный режим",
	format = "Формат",
	scratch = "Диск?",
	played = "Сыгранные",
}

localization.textResult = {
	score = "КОЛ-ВО ОЧКОВ",
	accuracy = "ТОЧНОСТЬ",
	inputMode = "РЕЖИМ",
	timeRate = "УСКОРЕНИЕ",
	pauses = "КОЛ-ВО ПАУЗ",
	scrollSpeed = "ТИП ПРОКРУТКИ",
	noPatterns = "Нет паттернов",
	noAccuracy = "Нет точности",
}

localization.textMultiplayer = {
	title = "Мультиплеер ",
	noPlayers = "Нет игроков в сети.",
	players = "Игроки:",
	createTip = "Создайте вашу собственную комнату:",
	createRoom = "Создать комнату",
	playing = "В игре",
	name = "Название",
	password = "Пароль",
	create = "Создать",
	enterPassword = "Введите пароль чтобы присоединиться к %s",
	back = "Назад",
	notConnected = "Пытаемся подключиться.\nСтатус: %s",
}

localization.textMultiplayerScreen = {
	roomName = "Название комнаты: %s",
	playerCount = "Игроки: %i",
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
	keybinds = "Key binds",
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
	showKeybinds = "Show keybinds window",
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
		hitError = { "ZenMaruGothic-Medium", 16 },
		judgements = { "ZenMaruGothic-Medium", 24 },
		accuracy = { "ZenMaruGothic-Medium", 28 },
		scoreInfo = { "ZenMaruGothic-Medium", 24 },
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
}

return localization
