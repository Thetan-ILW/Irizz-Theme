local Assets = require("thetan.skibidi.models.AssetModel.Assets")

local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")

---@class (exact) osu.OsuSelectAssets : skibidi.Assets
---@operator call: osu.OsuSelectAssets
---@field defaultsDirectory string
---@field skinPath string
---@field images table<string, love.Image>
---@field sounds table<string, audio.Source?>
---@field params table<string, number|string|boolean>
local OsuSelectAssets = Assets + {}

OsuSelectAssets.defaultsDirectory = "resources/osu_default_assets/"

local default_skin_ini = {
	Colours = {
		SongSelectActiveText = "0,0,0",
		SongSelectInactiveText = "255,255,255",
	},
}

function OsuSelectAssets:new(skin_path)
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

	self.params = {
		songSelectActiveText = skin_ini.Colours.SongSelectActiveText,
		songSelectInactiveText = skin_ini.Colours.SongSelectInactiveText,
	}

	self.images = {
		avatar = self.loadImage("userdata/avatar") or self.emptyImage(),
		panelTop = self:loadImageOrDefault(skin_path, "songselect-top"),

		panelBottom = self:loadImageOrDefault(skin_path, "songselect-bottom"),
		rankedIcon = self:loadImageOrDefault(skin_path, "selection-ranked"),
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

		gradeD = self:loadImageOrDefault(skin_path, "ranking-D-small"),
		gradeC = self:loadImageOrDefault(skin_path, "ranking-C-small"),
		gradeB = self:loadImageOrDefault(skin_path, "ranking-B-small"),
		gradeA = self:loadImageOrDefault(skin_path, "ranking-A-small"),
		gradeS = self:loadImageOrDefault(skin_path, "ranking-S-small"),
		gradeX = self:loadImageOrDefault(skin_path, "ranking-X-small"),
	}

	self.sounds = {
		selectChart = self:loadAudioOrDefault(skin_path, "select-difficulty"),
		selectGroup = self:loadAudioOrDefault(skin_path, "select-expand"),
		backButtonClick = self:loadAudioOrDefault(skin_path, "back-button-click"),
		hoverSelectableBox = self:loadAudioOrDefault(skin_path, "click-short"),
		hoverAboveCharts = self:loadAudioOrDefault(skin_path, "menuclick"),
		hoverMenuBack = self:loadAudioOrDefault(skin_path, "menu-back-hover"),
	}

	self.images.panelTop:setWrap("clamp")
end

return OsuSelectAssets
