return {
	-- Input
	insertMode = "i",
	normalMode = "escape",
	deleteLine = { op = { "d", "d" } },
	quit = { mod = { "lshift", "rshift" }, "escape" },

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
	moveScreenLeft = { mod = { "lctrl", "rctrl" }, "h" },
	moveScreenRight = { mod = { "lctrl", "rctrl" }, "l" },
	pauseMusic = { mod = { "lctrl", "rctrl" }, "p" },
	autoPlay = { mod = { "lctrl", "rctrl" }, "return" },
	watchReplay = "w",
	retry = "r",
	submitScore = "s",

	-- Movement
	up = "k",
	down = "j",
	left = "h",
	right = "l",
	up10 = { mod = { "lctrl", "rctrl" }, "u" },
	down10 = { mod = { "lctrl", "rctrl" }, "d" },
	toStart = { op = { "g", "g" } },
	toEnd = { mod = { "lshift", "rshift" }, "g" },
}
