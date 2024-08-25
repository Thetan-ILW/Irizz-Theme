local Assets = require("thetan.skibidi.models.AssetModel.Assets")
local Localization = require("thetan.skibidi.models.AssetModel.Localization")

local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")

---@class (exact) osu.OsuAssets : skibidi.Assets
---@operator call: osu.OsuAssets
---@field defaultsDirectory string
---@field skinPath string
---@field images table<string, love.Image>
---@field imageFonts table<string, table<string, string>>
---@field sounds table<string, audio.Source?>
---@field params table<string, number|string|boolean>
---@field localization skibidi.Localization
---@field selectViewConfig function?
---@field resultViewConfig function?
local OsuAssets = Assets + {}

OsuAssets.defaultsDirectory = "resources/osu_default_assets/"

local default_skin_ini = {
	Colours = {
		SongSelectActiveText = "0,0,0",
		SongSelectInactiveText = "255,255,255",
	},
	Fonts = {
		ScorePrefix = "score",
		ScoreOverlap = 0,
		accuracyNameX = 0,
		accuracyNameY = 0,
	},
}

local characters = {
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"comma",
	"dot",
	"percent",
	"x",
}

local char_alias = {
	comma = ",",
	dot = ".",
	percent = "%",
}

---@param group string
---@return table<string, string>
local function getImageFont(group)
	---@type table<string, string>
	local font = {}

	for _, v in ipairs(characters) do
		local file = Assets.findImage(("%s-%s"):format(group, v))

		if file then
			local key = char_alias[v] and char_alias[v] or v
			font[key] = file
		end
	end

	return font
end

---@param skin_path string
---@param localization_file string
function OsuAssets:new(skin_path, localization_file)
	self.skinPath = skin_path

	local content = love.filesystem.read(skin_path .. "skin.ini") or love.filesystem.read(skin_path .. "Skin.ini")

	---@type table
	local skin_ini

	if content then
		content = utf8validate(content)
		skin_ini = OsuNoteSkin:parseSkinIni(content)
	else
		skin_ini = default_skin_ini
	end

	self:loadLocalization(localization_file)

	self.params = {
		songSelectActiveText = skin_ini.Colours.SongSelectActiveText,
		songSelectInactiveText = skin_ini.Colours.SongSelectInactiveText,

		scoreOverlap = skin_ini.Fonts.ScoreOverlap or 0,
		accuracyNameX = skin_ini.Fonts.accuracyNameX or 0,
		accuracyNameY = skin_ini.Fonts.accuracyNameY or 0,
	}

	self.images = {
		avatar = self.loadImage("userdata/avatar") or self.emptyImage(),
		panelTop = self:loadImageOrDefault(skin_path, "songselect-top"),

		panelBottom = self:loadImageOrDefault(skin_path, "songselect-bottom"),
		rankedIcon = self:loadImageOrDefault(skin_path, "selection-ranked"),
		danIcon = self:loadImageOrDefault(skin_path, "selection-dan"),
		dropdownArrow = self:loadImageOrDefault(skin_path, "dropdown-arrow"),

		menuBack = self:loadImageOrDefault(skin_path, "menu-back"),
		modeButton = self:loadImageOrDefault(skin_path, "selection-mode"),
		modsButton = self:loadImageOrDefault(skin_path, "selection-mods"),
		randomButton = self:loadImageOrDefault(skin_path, "selection-random"),
		optionsButton = self:loadImageOrDefault(skin_path, "selection-options"),

		modeButtonOver = self:loadImageOrDefault(skin_path, "selection-mode-over"),
		modsButtonOver = self:loadImageOrDefault(skin_path, "selection-mods-over"),
		randomButtonOver = self:loadImageOrDefault(skin_path, "selection-random-over"),
		optionsButtonOver = self:loadImageOrDefault(skin_path, "selection-options-over"),

		osuLogo = self:loadImageOrDefault(skin_path, "menu-osu"),
		tab = self:loadImageOrDefault(skin_path, "selection-tab"),
		forum = self:loadImageOrDefault(skin_path, "rank-forum"),
		noScores = self:loadImageOrDefault(skin_path, "selection-norecords"),

		listButtonBackground = self:loadImageOrDefault(skin_path, "menu-button-background"),
		star = self:loadImageOrDefault(skin_path, "star"),
		maniaSmallIcon = self:loadImageOrDefault(skin_path, "mode-mania-small"),
		maniaSmallIconForCharts = self:loadImageOrDefault(skin_path, "mode-mania-small-for-charts"),
		maniaIcon = self:loadImageOrDefault(skin_path, "mode-mania"),

		buttonLeft = self:loadImageOrDefault(skin_path, "button-left"),
		buttonMiddle = self:loadImageOrDefault(skin_path, "button-middle"),
		buttonRight = self:loadImageOrDefault(skin_path, "button-right"),

		smallGradeD = self:loadImageOrDefault(skin_path, "ranking-D-small"),
		smallGradeC = self:loadImageOrDefault(skin_path, "ranking-C-small"),
		smallGradeB = self:loadImageOrDefault(skin_path, "ranking-B-small"),
		smallGradeA = self:loadImageOrDefault(skin_path, "ranking-A-small"),
		smallGradeS = self:loadImageOrDefault(skin_path, "ranking-S-small"),
		smallGradeX = self:loadImageOrDefault(skin_path, "ranking-X-small"),

		cursor = self:loadImageOrDefault(skin_path, "cursor"),
		cursorTrail = self:loadImageOrDefault(skin_path, "cursortrail"),

		uiLock = self:loadImageOrDefault(skin_path, "ui-lock"),

		-- MAIN MENU

		background = self:loadImageOrDefault(skin_path, "menu-background"),
		copyright = self:loadImageOrDefault(skin_path, "menu-copyright"),
		nowPlaying = self:loadImageOrDefault(skin_path, "menu-np"),
		musicPause = self:loadImageOrDefault(skin_path, "menu-pause-music"),
		musicToStart = self:loadImageOrDefault(skin_path, "menu-to-music-start"),
		musicPlay = self:loadImageOrDefault(skin_path, "menu-play-music"),
		musicBackwards = self:loadImageOrDefault(skin_path, "menu-music-backwards"),
		musicForwards = self:loadImageOrDefault(skin_path, "menu-music-forwards"),
		musicInfo = self:loadImageOrDefault(skin_path, "menu-music-info"),
		musicList = self:loadImageOrDefault(skin_path, "menu-music-list"),
		directButton = self:loadImageOrDefault(skin_path, "menu-osudirect"),
		directButtonOver = self:loadImageOrDefault(skin_path, "menu-osudirect-over"),

		-- RESULT

		title = self:loadImageOrDefault(skin_path, "ranking-title"),
		panel = self:loadImageOrDefault(skin_path, "ranking-panel"),
		graph = self:loadImageOrDefault(skin_path, "ranking-graph"),
		maxCombo = self:loadImageOrDefault(skin_path, "ranking-maxcombo"),
		accuracy = self:loadImageOrDefault(skin_path, "ranking-accuracy"),
		replay = self:loadImageOrDefault(skin_path, "pause-replay"),

		judgeMarvelous = self:loadImageOrDefault(skin_path, "mania-hit300g"),
		judgePerfect = self:loadImageOrDefault(skin_path, "mania-hit300"),
		judgeGreat = self:loadImageOrDefault(skin_path, "mania-hit200"),
		judgeGood = self:loadImageOrDefault(skin_path, "mania-hit100"),
		judgeBad = self:loadImageOrDefault(skin_path, "mania-hit50"),
		judgeMiss = self:loadImageOrDefault(skin_path, "mania-hit0"),

		gradeSS = self:loadImageOrDefault(skin_path, "ranking-X"),
		gradeS = self:loadImageOrDefault(skin_path, "ranking-S"),
		gradeA = self:loadImageOrDefault(skin_path, "ranking-A"),
		gradeB = self:loadImageOrDefault(skin_path, "ranking-B"),
		gradeC = self:loadImageOrDefault(skin_path, "ranking-C"),
		gradeD = self:loadImageOrDefault(skin_path, "ranking-D"),

		noLongNote = self:loadImageOrDefault(skin_path, "selection-mod-nolongnote"),
		mirror = self:loadImageOrDefault(skin_path, "selection-mod-mirror"),
		random = self:loadImageOrDefault(skin_path, "selection-mod-random"),
		doubleTime = self:loadImageOrDefault(skin_path, "selection-mod-doubletime"),
		halfTime = self:loadImageOrDefault(skin_path, "selection-mod-halftime"),
		autoPlay = self:loadImageOrDefault(skin_path, "selection-mod-autoplay"),
		automap4 = self:loadImageOrDefault(skin_path, "selection-mod-key4"),
		automap5 = self:loadImageOrDefault(skin_path, "selection-mod-key5"),
		automap6 = self:loadImageOrDefault(skin_path, "selection-mod-key6"),
		automap7 = self:loadImageOrDefault(skin_path, "selection-mod-key7"),
		automap8 = self:loadImageOrDefault(skin_path, "selection-mod-key8"),
		automap9 = self:loadImageOrDefault(skin_path, "selection-mod-key9"),
		automap10 = self:loadImageOrDefault(skin_path, "selection-mod-key10"),
	}

	local score_font_path = skin_path .. skin_ini.Fonts.ScorePrefix or skin_path .. "score"

	self.imageFonts = {
		scoreFont = getImageFont(score_font_path),
	}

	self.sounds = {
		selectChart = self:loadAudioOrDefault(skin_path, "select-difficulty"),
		selectGroup = self:loadAudioOrDefault(skin_path, "select-expand"),
		backButtonClick = self:loadAudioOrDefault(skin_path, "back-button-click"),
		hoverSelectableBox = self:loadAudioOrDefault(skin_path, "click-short"),
		hoverAboveCharts = self:loadAudioOrDefault(skin_path, "menuclick"),
		hoverMenuBack = self:loadAudioOrDefault(skin_path, "menu-back-hover"),

		applause = self:loadAudioOrDefault(skin_path, "applause"),
		menuBack = self:loadAudioOrDefault(skin_path, "menuback"),
		switchScreen = self:loadAudioOrDefault(skin_path, "menuhit"),
	}

	self.images.panelTop:setWrap("clamp")

	self.selectViewConfig = love.filesystem.load(skin_path .. "SelectViewConfig.lua")
	self.resultViewConfig = love.filesystem.load(skin_path .. "ResultViewConfig.lua")

	for _, v in ipairs(self.errors) do
		print(v)
	end
end

---@param filepath string
function OsuAssets:loadLocalization(filepath)
	if not self.localization then
		self.localization = Localization(filepath, 768)
		return
	end

	if self.localization.currentFilePath ~= filepath then
		self.localization:loadFile(filepath)
	end
end

return OsuAssets
