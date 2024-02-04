local localization = {}

localization.text = {
	-- Header
	settings = "設定",
	songs = "曲",
	collections = "コレクション",

	-- Song select
	noCharts = "チャートがありません！",
	noChartSets = "チャートセットがありません！",
	noScores = "スコアがありません！",
	length = "%s 長さ",
	notes = "%s ノート",
	bpm = "%i BPM",
	ln = "%i%% LN",
	searchPlaceholder = "検索するには入力してください...",
	filterPlaceholder = "フィルターがありません。",

	-- Collections
	queueEmpty = "キューは空です！",
	notInOsuDirect = "osu!directモードではありません！",
	noCollections = "コレクションがありません！",
	cache = "キャッシュ",
	osuDirect = "osu!direct",
	mounts = "マウント",
	searching = "ステータス: チャートを検索中: %d",
	creatingCache = "ステータス: キャッシュを作成中: %0.2f%%",
	complete = "ステータス: 完了！",
	idle = "ステータス: 何もしていません",
	download = "ダウンロード",
	redownload = "再ダウンロード"
}

localization.fontFamilyList = {
    ["ZenMaruGothic-Black"] = {
        "iris/fonts/ZenMaruGothic/ZenMaruGothic-Black.ttf"
    },
	["ZenMaruGothic-Medium"] = {
        "iris/fonts/ZenMaruGothic/ZenMaruGothic-Medium.ttf"
    },
	["Comfortaa-Medium"] = {
		"iris/fonts/Comfortaa/Comfortaa-Medium.ttf"
	}
}

localization.fonts = {
	header = {
		anyText = {"ZenMaruGothic-Medium", 24}
	},

	settingsViewConfig = {
		tabs = {"ZenMaruGothic-Medium", 28},
	},

	songSelectViewConfig = {
		searchField = {"ZenMaruGothic-Black", 36},
		difficulty = {"ZenMaruGothic-Medium", 28},
		calculator = {"ZenMaruGothic-Medium", 24},
		patterns = {"ZenMaruGothic-Black", 24},
		info = {"ZenMaruGothic-Medium", 28},
		moreInfo = {"ZenMaruGothic-Medium", 28},
		timeRate = {"ZenMaruGothic-Medium", 32},
		mods = {"ZenMaruGothic-Medium", 24},
		titleAndDifficulty = {"ZenMaruGothic-Black", 32}
	},

	collectionsViewConfig = {
		status = {"ZenMaruGothic-Black", 36},
		queue = {"ZenMaruGothic-Medium", 32}, --
		osuDirectCharts = {"ZenMaruGothic-Medium", 32}, --
		buttons = {"ZenMaruGothic-Medium", 28},
		titleAndMode = {"ZenMaruGothic-Black", 32}
	},

	listView = {
		noItems = {"ZenMaruGothic-Medium", 36}
	},

	noteChartListView = {
		inputMode = {"ZenMaruGothic-Black", 18},
		difficulty = {"ZenMaruGothic-Black", 24},
		creator = {"ZenMaruGothic-Black", 18},
		name = {"ZenMaruGothic-Black", 24}
	},

	noteChartSetListView = {
		artist = {"ZenMaruGothic-Black", 18},
		title = {"ZenMaruGothic-Black", 24}
	},

	collectionsListView = {
		shortPath = {"ZenMaruGothic-Black", 18},
		itemCount = {"ZenMaruGothic-Black", 24},
		name = {"ZenMaruGothic-Black", 24}
	},

	scoreListView = {
		line1 = {"ZenMaruGothic-Black", 22},
		line2 = {"ZenMaruGothic-Black", 20}
	},

	osuDirectListView = {
		artist = {"ZenMaruGothic-Black", 18},
		title = {"ZenMaruGothic-Black", 24}
	},

	osuDirectChartsListView = {
		creator = {"ZenMaruGothic-Black", 18},
		difficultyName = {"ZenMaruGothic-Black", 24}
	},

	osuDirectQueueListView = {
		title = {"ZenMaruGothic-Black", 24},
		artist = {"ZenMaruGothic-Black", 14},
		status = {"ZenMaruGothic-Black", 14}
	}
}

return localization