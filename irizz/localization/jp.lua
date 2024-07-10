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
	gameplayTab = "ゲームプレイ",
	audioTab = "SE/SFX",
	videoTab = "ビデオ",
	timingsTab = "タイミング",
	keybindsTab = "キー設定",
	inputsTab = "入力",
	uiTab = "UI",
	versionTab = "バージョン",
	--
	scrollSpeed = "スクロール速度",
	speedType = "速度タイプ",
	actionOnFail = "失敗時のアクション",
	actionNone = "なし",
	actionPause = "一時停止",
	actionQuit = "終了",
	scaleScrollSpeed = "レートに応じてスクロール速度を調整",
	lnShortening = "LN短縮",
	tempoFactor = "テンポ係数",
	primaryTempo = "主要テンポ",
	lastMeanValues = "最後の平均値",
	taikoSV = "太鼓SV",
	hp = "ゲージ/HP",
	hpShift = "自動シフト",
	hpNotes = "最大ヘルス",
	waitTime = "待機時間（秒）",
	prepare = "準備",
	playPause = "再生→一時停止",
	pausePlay = "一時停止→再生",
	playRetry = "再生→リトライ",
	pauseRetry = "一時停止→リトライ",
	--
	ratingHitWindow = "判定ウィンドウ",
	inputOffest = "入力オフセット",
	visualOffset = "視覚オフセット",
	multiplyInputOffset = "入力オフセットを時間レートで乗算",
	multiplyVisualOffset = "視覚オフセットを時間レートで乗算",
	--
	volumeType = "ボリュームタイプ",
	logarithmic = "対数",
	master = "マスター",
	music = "音楽",
	effects = "効果音",
	metronome = "メトロノーム",
	uiVolume = "UI",
	audioPitch = "タイムレートがピッチを変更",
	autoKeySound = "オートキーサウンド",
	adjustRate = "タイマー調整率",
	midiConstantVolume = "MIDI一定音量",
	latency = "レイテンシー: ",
	updatePeriod = "更新期間",
	bufferLength = "バッファ長",
	apply = "適用",
	reset = "リセット",
	--
	fpsLimit = "FPS制限",
	fullscreen = "フルスクリーン",
	fullscreenType = "フルスクリーンタイプ",
	vsync = "Vsync",
	vsyncOnSelect = "曲選択画面でのVsync",
	dwmFlush = "DWMフラッシュ",
	threadedInput = "スレッド入力",
	startupWindowResolution = "起動時のウィンドウ解像度",
	cursor = "カーソル",
	backgroundAnimation = "背景アニメーション",
	video = "ビデオ",
	image = "画像",
	camera = "カメラ",
	enableCamera = "カメラを有効にする",
	allowRotateX = "X軸の回転を許可",
	allowRotateY = "Y軸の回転を許可",
	--
	offset = "オフセット",
	timeRate = "タイムレート",
	pause = "一時停止",
	none = "なし",
	quit = "終了",
	skipIntro = "イントロをスキップ",
	quickRestart = "再起動",
	increase = "増加",
	decrease = "減少",
	selectRandom = "ランダム選択",
	captureScreenshot = "スクリーンショットを撮る",
	openScreenshot = "スクリーンショットを開く",
	--
	dim = "ディム",
	blur = "ブラー",
	showOnlineCount = "オンラインプレイヤー数を表示",
	showSpectrum = "スペクトルアナライザーを表示",
	backgroundEffects = "背景エフェクト",
	panelBlur = "パネルの下をぼかす",
	ch_ab = "Chromatic aberration",
	distortion = "歪み",
	spectrum = "スペクトルアナライザーの色",
	solid = "単色",
	inverted = "反転色",
	select = "曲選択",
	collections = "コレクション",
	gameplay = "ゲームプレイ",
	result = "結果",
	groupCharts = "チャートをグループ化",
	alwaysShowOriginalMode = "常に元の入力モードを表示",
	rateType = "レートタイプ",
	linear = "Linear",
	exp = "Exp",
	language = "言語 (Language)",
	colorTheme = "色のテーマ",
	vimMotions = "Vimモーション",
	scrollAcceleration = "スクロール加速度",
	scrollClickExtraTime = "スクロールクリック余分な時間",
	transitionAnimation = "トランジションアニメーション",
	fade = "フェード",
	shutter = "Shutter",
	chartPreview = "チャートプレビュー",
	songSelectOffset = "曲選択オフセット",
	--
	osuResultScreen = "osu! 結果画面",
	enable = "有効化",
	showHpGraph = "HPグラフを表示",
	showPP = "PPを表示",
	skin = "スキン",
	--
	commit = "Commit: ",
	commitDate = "Commit date: ",
	contributors = "貢献者に感謝:",
	--
	scoring = "スコアリング",
	scoreSystem = "スコアシステム",
	judgement = "判定",
	nearest = "最も近いノートのスコアリング",
	noteHitWindow = "ノートヒットウィンドウ",
	noteMissWindow = "ノートミスウィンドウ",
	lnHitWindow = "LNヒットウィンドウ",
	lnMissWindow = "LNミスウィンドウ",
	early = "（早い）",
	late = "（遅い）",
	releaseHitWindow = "リリースヒットウィンドウ",
	releaseMissWindow = "リリースミスウィンドウ",
	--
	default = "デフォルト",
	osu = "osu!",
	average = "平均",
	primary = "プライマリ",
	minimum = "最小",
	maximum = "最大",
	desktop = "デスクトップ",
	exclusive = "専用",
	enabled = "有効",
	disabled = "無効",
	adaptive = "適応型",
	circle = "円",
	arrow = "矢印",
	system = "システム",
	other = "その他",
	volume = "音量",
	audioDevice = "オーディオデバイス",
	bpm = "%i BPM",
	noMods = "修飾なし",
	const = "一定のスクロール速度",
	singleNoteHandler = "太鼓ノートハンドラー",
	muteOnUnfocus = "フォーカス外でゲームをミュート",
	autoUpdate = "自動更新",
	showNonManiaCharts = "非マニア譜面を表示",
	difficulty = "「難易度タイプ」",
	startSound = "開始音",
	staticCursor = "リストで静的カーソル",
	showLocations = "場所を表示",
	chartFormatOffsets = "譜面形式のオフセット",
	audioModeOffsets = "オーディオモードのオフセット",
	chartLengthBeforeArtist = "譜面リストで譜面の長さを表示",
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
	noMods = "No modifiers.\nClick here to select.",
}

localization.textCollections = {
	collections = "コレクション",
	osuDirect = "osu!direct",
	mounts = "マウント",
	searching = "ステータス: チャートを検索中: %d",
	creatingCache = "ステータス: キャッシュを作成中: %0.2f%%",
	download = "ダウンロード",
	redownload = "再ダウンロード",
	wait = "少しお待ちください...",
	osuDirectSearchPlaceholder = "検索するには入力してください...",
	locations = "Locations",
	directories = "Directories",
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
	computeMissing = "不足分を計算",
	computeIncomplete = "不完全な部分を計算",
	computeIncompleteUsePreview = "不完全な部分を計算、プレビューを使用",
	computed = "計算済み: %i",
	notSpecified = "Not specified",
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
	timeRate = "時間倍率: %0.02fx",
	pauses = "ポーズ:",
	grade = "成績:",
	scrollSpeed = "スクロール速度:",
	hitWindow = "ヒットウィンドウ",
	missWindow = "ミスウィンドウ",
	releaseMultiplier = "リリース倍率",
	hitLogic = "ヒットロジック",
	nearest = "Nearest",
	earliestNote = "Earliest",
	noPatterns = "パターンなし",
	mode = "モード: ",
	score = "スコア: ",
	accuracy = "精度: ",
	rating = "評価: ",
	mean = "平均: ",
	maxError = "最大誤差: ",
	noMods = "モッドなし。",
}

localization.textOsuResult = {
	chartBy = "譜面作成者: %s",
	chartFrom = "譜面提供元: %s",
	playedBy = "%s が %s にプレイ",
	mean = "平均: %s",
	maxError = "最大誤差: %s",
	scrollSpeed = "スクロール速度: %s",
	mods = "モッド: %s",
	guest = "ゲスト",
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
	welcomeToNoesis = "Welcome to Noesis!",
	welcomeToSoundsphere = "Welcome to soundsphere!",
}

localization.textPauseSubscreen = {
	paused = { "ゲ", "ー", "ム", "が", "一", "時", "停", "止", "中" },
	resume = "再開",
	retry = "やり直し",
	quit = "終了",
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

	pauseSubscreen = {
		paused = { "ZenMaruGothic-Black", 56 },
		buttons = { "ZenMaruGothic-Medium", 48 },
	},
}

return localization
