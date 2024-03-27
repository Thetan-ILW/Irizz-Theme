return {
    songSelect = {
        play = "return",
        showMods = "f1",
        random = "f2",
        decreaseTimeRate = "f5",
        increaseTimeRate = "f6",
        undoRandom = { mod = { "lctrl", "rctrl" }, "f2" },
        clearSearch = { mod = { "lctrl", "rctrl" }, "backspace" },
        moveScreenLeft = { mod = { "lctrl", "rctrl" }, "h" },
        moveScreenRight = { mod = { "lctrl", "rctrl" }, "l" },
        pauseMusic = { mod = { "lctrl", "rctrl" }, "p" },
        showSkins = { mod = { "lctrl", "rctrl" }, "s" },
        showFilters = { mod = { "lctrl", "rctrl" }, "f" },
        showInputs = { mod = { "lctrl", "rctrl" }, "i" },
        showMultiplayer = { mod = { "lctrl", "rctrl" }, "m" },
        autoPlay = { mod = { "lctrl", "rctrl" }, "return" },
        openEditor = { mod = { "lctrl", "rctrl" }, "e" },
        insertMode = "i",
        normalMode = "escape"
    },
    resultScreen = {
        songSelect = "escape",
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
