local localization = {}

localization.language = "日本語"

localization.textHeader = {
	settings = "設定",
	songs = "曲",
	collections = "コレクション",
	notLoggedIn = "オフライン",
	online = "オンライン: %i",
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
	noItems = "チャートが選択されていません。\n入力モードを決定できません。",
}

localization.textNoteSkinsList = {
	noItems = "No note skins.",
}

localization.textRoomsList = {
	noItems = "部屋がありません。\n自分で作成して友達を招待しましょう！",
	playing = "プレイ中",
	join = "参加",
	room = "部屋: %s",
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
	update = "更新",
	deleteCache = "キャッシュを削除",
	processingCharts = "チャートを処理中...",
	path = "パス",
	chartsFound = "処理済み / 見つかった",
	chartsCached = "キャッシュされたチャート",
	create = "作成",
	delete = "削除",
	locations = "場所",
	database = "データベース",
	chartdiffs = "チャートの難易度 / レーティング",
	chartmetas = "チャートのメタデータ",
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

localization.textFilters = {
	filters = "フィルター",
	moddedCharts = "修正されたチャートを表示",
	chartCount = "%i チャート in '%s'",
	charts = "チャート",
	scores = "スコア",
	scoresSource = "スコアのソース",
	inputMode = "モード",
	actualInputMode = "実際のモード",
	format = "フォーマット",
	scratch = "スクラッチ",
	played = "プレイ済み",
}

localization.textResult = {
	score = "スコア",
	accuracy = "精度",
	inputMode = "入力モード",
	timeRate = "レート",
	pauses = "一時停止",
	scrollSpeed = "スクロール速度",
	noPatterns = "パターンがありません",
	noAccuracy = "精度がありません",
}

localization.textMultiplayer = {
	title = "マルチプレイヤーとプレイヤー",
	noPlayers = "オンラインの人はいません。",
	players = "プレイヤー:",
	createTip = "自分の部屋を作成:",
	createRoom = "部屋を作成",
	name = "名前",
	password = "パスワード",
	create = "作成",
	enterPassword = "%sに参加するためのパスワードを入力",
	back = "戻る",
	notConnected = "接続を試みています。\nステータス: %s",
}

localization.textMultiplayerScreen = {
	roomName = "ルーム名前: %s",
	playerCount = "プレイヤー: %i",
}

localization.textChartInfo = {
	chartInfo = "チャート情報",
	artist = "アーティスト",
	title = "タイトル",
	chartName = "名前",
	bpm = "BPM",
	tags = "タグ",
	source = "ソース",
	chartFormat = "フォーマット",
	setName = "セット名",
	path = "パス",
	audioPath = "オーディオパス",
	backgroundPath = "背景パス",
	mode = "モード",
	chartFileName = "チャートファイル名",
	hash = "MD5ハッシュ",
}

localization.textKeybinds = {
	keybinds = "キーバインド",
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
		noItems = { "ZenMaruGothic-Medium", 24 },
	},

	noteChartSetListView = {
		artist = { "ZenMaruGothic-Black", 18 },
		title = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 24 },
	},

	collectionsListView = {
		itemCount = { "ZenMaruGothic-Black", 18 },
		name = { "ZenMaruGothic-Black", 24 },
		noItems = { "ZenMaruGothic-Medium", 36 },
	},

	scoreListView = {
		line1 = { "ZenMaruGothic-Black", 20 },
		line2 = { "ZenMaruGothic-Black", 18 },
		noItems = { "ZenMaruGothic-Medium", 24 },
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
		keybinds = { "ZenMaruGothic-Black", 24 },
	},

	chartInfoModal = {
		title = { "ZenMaruGothic-Black", 72 },
		info = { "ZenMaruGothic-Medium", 24 },
	},
}

return localization
