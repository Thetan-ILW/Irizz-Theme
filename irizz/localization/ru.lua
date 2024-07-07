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
	gameplayTab = "Геймплей",
	audioTab = "Аудио",
	videoTab = "Видео",
	timingsTab = "Тайминги",
	keybindsTab = "Привязка клавиш",
	inputsTab = "Ввод",
	uiTab = "Интерфейс",
	versionTab = "Версия",
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
	ratingHitWindow = "Окно попадания в рейтинг",
	inputOffest = "Сдвиг ввода",
	visualOffset = "Визуальный сдвиг",
	multiplyInputOffset = "Увеличивать сдвиг ввода по скорости музыки",
	multiplyVisualOffset = "Увеличивать визульный сдвиг по скорости музыки",
	--
	volumeType = "Тип звука",
	logarithmic = "Логарифмический",
	master = "Общее",
	music = "Музыка",
	effects = "Эффекты",
	metronome = "Метроном",
	uiVolume = "Интерфейс",
	audioPitch = "Скорость музыки меняет питч",
	autoKeySound = "Auto key sound?",
	adjustRate = "Скорость регулировки по таймеру",
	midiConstantVolume = "Постоянная громкость MIDI",
	latency = "Задержка: ",
	updatePeriod = "Период обновления",
	bufferLength = "Длина буфера",
	apply = "Применить",
	reset = "Сбросить",
	--- добавить ещё 2 настройки
	--
	fpsLimit = "Лимит ФПС",
	fullscreen = "Полный экран",
	fullscreenType = "Вид полного экрана",
	vsync = "Вертикальная синхронизация",
	vsyncOnSelect = "Вертикальная синхронизация во время экрана выбора карты",
	dwmFlush = "DWM flush?", -- смыв не подходит
	threadedInput = "Threaded input?", -- тут без понятия ничего не подходит + нет этой настройки
	startupWindowResolution = "Разрешение экрана",
	cursor = "Курсор",
	backgroundAnimation = "Анимации заднего фона",
	video = "Видео",
	image = "Изображение",
	camera = "Камера",
	enableCamera = "Включить камеру",
	allowRotateX = "Разрешить поворот по координате X",
	allowRotateY = "Разрешить поворот по координате Y",
	--- добавить перевод в окнах выбора
	--
	offset = "Сдвиг",
	timeRate = "Скорость музыки",
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
	dim = "Затемнение",
	blur = "Блюр", -- или размытие
	showOnlineCount = "Показывать кол-во игроков в онлайне",
	showSpectrum = "Показывать спектроанализатор",
	backgroundEffects = "Эффекты заднего фона",
	panelBlur = "Блюр под панелями", -- или размытие
	ch_ab = "Хроматизм",
	distortion = "Дисторция",
	spectrum = "Цвет спектроанализатора",
	solid = "Цвет",
	inverted = "Инверсия",
	select = "Выбор песни",
	collections = "Коллекции",
	gameplay = "Геймплей",
	result = "Результат",
	groupCharts = "Группировать карты",
	rateType = "Тип скорости карты",
	linear = "Линейный",
	exp = "Exp?", -- экспоненциальный наверное не знаю сокращения xD
	colorTheme = "Цвет темы",
	vimMotions = "Vim передвижения",
	scrollAcceleration = "Ускорение прокрутки",
	scrollClickExtraTime = "Scroll click extra time?", --для прокрутки нажать ещё раз
	chartPreview = "Предпросмотр карты",
	songSelectOffset = "Сдвиг выбора песен",
	--- добавить ещё 3 найтроки + result screen
	--
	commit = "Commit: ", -- i dunno
	commitDate = "Последние изменения: ",
	--
	scoring = "Оценивание",
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
	average = "Среднее",
	primary = "Основной",
	minimum = "Минимум",
	maximum = "Максимум",
	desktop = "Desktop",
	exclusive = "Exclusive",
	enabled = "Enabled",
	disabled = "Disabled",
	adaptive = "Adaptive",
	circle = "Circle",
	arrow = "Arrow",
	system = "System",
	other = "Другое",
	volume = "Volume",
	audioDevice = "Audio device",
	bpm = "%i BPM",
	noMods = "No modifiers",
	const = "Постоянная скорость прокрутки",
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
	bpm = "%i BPM",
	ln = "%i%% ДЛ. НОТЫ",
	searchPlaceholder = "Введите чтобы найти...",
	filterPlaceholder = "Нет фильтров.",
	score = "Рекорд: %i",
	noPatterns = "Нет паттернов",
}

localization.textCollections = {
	collections = "Коллекции",
	osuDirect = "osu!direct",
	mounts = "Монтирование",
	download = "Загрузить",
	redownload = "Загрузить заново",
	wait = "Подождите...",
	osuDirectSearchPlaceholder = "Введите чтобы найти...",
	locations = "Locations",
	directories = "Directories",
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
	playing = "Игра в процессе",
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
	timeRate = "Скорость: %0.02fx",
	pauses = "Паузы:",
	grade = "Оценка:",
	scrollSpeed = "Скорость прокрутки:",
	hitWindow = "Окно нажатия",
	missWindow = "Окно промаха",
	releaseMultiplier = "Множитель отжатия",
	hitLogic = "Логика попадания",
	nearest = "Ближайшая",
	earliestNote = "Ранняя",
	noPatterns = "Нет паттернов",
	mode = "Режим: ",
	score = "Очки: ",
	accuracy = "Точность: ",
	rating = "Рейтинг: ",
	mean = "Среднее: ",
	maxError = "Макс. ошибка: ",
	noMods = "Без модификаторов",
}

localization.textOsuResult = {
	chartBy = "Карта от %s",
	chartFrom = "Карта из %s",
	playedBy = "Сыграно %s %s",
	mean = "Среднее: %s",
	maxError = "Максимальная ошибка: %s",
	scrollSpeed = "Скорость прокрутки: %s",
	mods = "Моды: %s",
	guest = "Гость",
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
	chartInfo = "Информация о карте",
	artist = "Исполнитель",
	title = "Название",
	chartName = "Название",
	bpm = "УВМ",
	tags = "Тэги",
	source = "Первоисточник",
	chartFormat = "Формат",
	setName = "Полное название",
	path = "Путь",
	audioPath = "Путь аудио",
	backgroundPath = "Путь фона",
	mode = "Кол-во клавиш",
	chartFileName = "Название файла карты",
	hash = "MD5 хэш",
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
	keybinds = "Привязка клавиш",
}

localization.keybindsGlobal = {
	insertMode = "Режим вставки",
	normalMode = "Обычный режим",
	quit = "Закрыть окно или уйти с экрана",
	showChartInfo = "Показать всю информацию об выбранной карте",
	showKeybinds = "Показать таблицу привязки клавиш (Вы находитесь здесь)",
}

localization.keybindsLargeList = {
	up = "Переместиться вверх по списку",
	down = "Переместиться вниз по списку",
	up10 = "Переместиться вверх 10 раз по списку",
	down10 = "Переместиться вниз 10 раз по списку",
	toStart = "Переместиться к началу списка",
	toEnd = "Переместиться к концу списка",
}

localization.keybindsSmallList = {
	up = "Переместиться вверх по малому списку",
	down = "Переместиться вниз по малому списку",
}

localization.keybindsSongSelect = {
	play = "Сыграть выбранную карту",
	showMods = "Показать модификаторы",
	random = "Выбрать случайную карту",
	decreaseTimeRate = "Уменьшить скорость музыки",
	increaseTimeRate = "Увеличить скорость музыки",
	undoRandom = "Вернуть прошлую случайную карту",
	clearSearch = "Очистить поле поиска",
	moveScreenLeft = "Переместить экран влево",
	moveScreenRight = "Переместить экран вправо",
	pauseMusic = "Поставить музыку на паузу",
	showSkins = "Показать доступные скины",
	showFilters = "Показать карту и фильтры рекордов",
	showInputs = "Показать настройки ввода",
	showMultiplayer = "Показать окно мультиплеера или вернуться в лобби",
	showKeybinds = "Показать окно привязки клавиш",
	autoPlay = "Запустить карту в режиме авто",
	openEditor = "Открыть редактор карты",
}

localization.keybindsResult = {
	watchReplay = "Посмотреть реплей",
	retry = "Перепройти карту",
	submitScore = "(Пере)отправить ваш рекорд",
}

localization.fontFamilyList = {
	["ZenMaruGothic-Black"] = {
		"irizz/fonts/ZenMaruGothic/ZenMaruGothic-Black.ttf",
	},
	["ZenMaruGothic-Medium"] = {
		"irizz/fonts/ZenMaruGothic/ZenMaruGothic-Medium.ttf",
	},
	["ZenMaruGothic-Regular"] = {
		"irizz/fonts/ZenMaruGothic/ZenMaruGothic-Regular.ttf",
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
		noMods = { "ZenMaruGothic-Medium", 18 },
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
		creator = { "ZenMaruGothic-Regular", 24 },
		playInfo = { "ZenMaruGothic-Regular", 24 },
		accuracy = { "ZenMaruGothic-Regular", 20 },
		graphInfo = { "ZenMaruGothic-Regular", 18 },
		pp = { "ZenMaruGothic-Medium", 36 },
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
