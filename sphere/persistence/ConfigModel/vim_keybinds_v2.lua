return {
	-- Input
	insertMode = "i",
	normalMode = "escape",
	deleteLine = { op = { "d", "d" } },
	quit = { mod = { "shift", "escape" } },

	-- Modals
	showKeybinds = { op = { "o", "k" } },
	showChartInfo = { op = { "o", "c" } },
	showMods = { op = { "o", "m" } },
	showSkins = { op = { "o", "s" } },
	showFilters = { op = { "o", "f" } },
	showInputs = { op = { "o", "i" } },
	showMultiplayer = { op = { "o", "p" } },
	openEditor = { op = { "o", "e" } },
	openResult = { op = { "o", "r" } },

	increaseVolume = "'",
	decreaseVolume = ";",
	play = "return",
	random = "r",
	decreaseTimeRate = "[",
	increaseTimeRate = "]",
	undoRandom = "u",
	moveScreenLeft = { mod = { "ctrl", "h" } },
	moveScreenRight = { mod = { "ctrl", "l" } },
	pauseMusic = { mod = { "ctrl", "p" } },
	autoPlay = { mod = { "ctrl", "return" } },
	watchReplay = "w",
	retry = "r",
	submitScore = "s",

	-- Movement
	up = "k",
	down = "j",
	left = "h",
	right = "l",
	up10 = { mod = { "ctrl", "u" } },
	down10 = { mod = { "ctrl", "d" } },
	toStart = { op = { "g", "g" } },
	toEnd = { mod = { "shift", "g" } },
}
