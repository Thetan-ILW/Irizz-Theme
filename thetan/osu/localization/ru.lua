local l = {}

l.textGroups = {
	songSelect = {
		group = "Группа",
		search = "Искать %s",
		noMatches = "Совпадений не найдено..",
		matchesFound = "%i совпадений найдено",
	},
	chartOptionsModal = {
		manageLocations = "1. Управление локациями",
		chartInfo = "2. Информация о карте",
		filters = "3. Фильтры",
		edit = "4. Редактировать",
		fileManager = "5. Открыть в файловом менеджере",
		cancel = "6. Отмена",
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
		groupSort = { "Aller", 30 },
		username = { "Aller", 20, "ZenMaruGothic-Medium" },
		belowUsername = { "Aller", 14 },
		rank = { "Aller-Light", 50 },
		scrollSpeed = { "Aller-Light", 23 },
		tabs = { "Aller", 14 },
		mods = { "Aller", 41 },
		search = { "Aller-Bold", 18, "ZenMaruGothic-Bold" },
		searchMatches = { "Aller-Bold", 15, "ZenMaruGothic-Bold" },
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
		buttons = { "Aller", 42, "ZenMaruGothic-Regular" },
	},
}

return l
