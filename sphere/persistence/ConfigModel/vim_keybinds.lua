return {
    global = {
        insertMode = "i",
        normalMode = "escape",
        quit = {mod = {"lshift", "rshift"}, "escape"}
    },
    songSelect = {
        play = "return",
        showMods = "f1",
        random = "f2",
        decreaseTimeRate = "f5",
        increaseTimeRate = "f6",
        undoRandom = { mod = { "lctrl", "rctrl" }, "f2" },
        clearSearch = { op = "dd" },
        moveScreenLeft = { mod = { "lctrl", "rctrl" }, "h" },
        moveScreenRight = { mod = { "lctrl", "rctrl" }, "l" },
        pauseMusic = { mod = { "lctrl", "rctrl" }, "p" },
        showSkins = { mod = { "lctrl", "rctrl" }, "s" },
        showFilters = { mod = { "lctrl", "rctrl" }, "f" },
        showInputs = { mod = { "lctrl", "rctrl" }, "i" },
        showMultiplayer = { mod = { "lctrl", "rctrl" }, "m" },
        showKeybinds = { mod = { "lctrl", "rctrl" }, "k" },
        autoPlay = { mod = { "lctrl", "rctrl" }, "return" },
        openEditor = { mod = { "lctrl", "rctrl" }, "e" },
    },
    resultScreen = {
        watchReplay = "w",
        retry = "r",
        submitScore = "s"
    },
    largeList = {
        up = "k",
        down = "j",
        up10 = {mod = { "lctrl", "rctrl" }, "u"},
        down10 = {mod = { "lctrl", "rctrl" }, "d"},
        toStart = {op = "gg"},
        toEnd = {mod = {"lshift", "rshift"}, "g"}
    },
    smallList = {
        up = "h",
        down = "l"
    }
}
