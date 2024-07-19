local Assets = require("thetan.skibidi.models.AssetModel.Assets")

local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")

---@class (exact) skibidi.OsuResultAssets : skibidi.Assets
---@operator call: skibidi.OsuResultAssets
---@field defaultsDirectory string
---@field images table<string, love.Image>
---@field sounds table<string, audio.Source?>
---@field params table<string, number|string|boolean>
---@field imageFonts table<string, table<string, string>>
---@field skinPath string
---@field customConfig (fun(): table)?
local OsuResultAssets = Assets + {}

OsuResultAssets.defaultsDirectory = "resources/osu_default_assets/"

local defaultSkinIni = {
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
		local file = OsuResultAssets.findImage(("%s-%s"):format(group, v))

		if file then
			local key = char_alias[v] and char_alias[v] or v
			font[key] = file
		end
	end

	return font
end

---@param skin_path string
function OsuResultAssets:new(skin_path)
	self.skinPath = skin_path
	skin_path = skin_path .. "/"

	local content = love.filesystem.read(skin_path .. "skin.ini")

	---@type table
	local skinini

	if content then
		content = utf8validate(content)
		skinini = OsuNoteSkin:parseSkinIni(content)
	else
		skinini = defaultSkinIni
	end

	local score_font_path = skin_path .. skinini.Fonts.ScorePrefix or skin_path .. "score"

	self.params = {
		scoreOverlap = skinini.Fonts.ScoreOverlap or 0,
		accuracyNameX = skinini.Fonts.accuracyNameX or 0,
		accuracyNameY = skinini.Fonts.accuracyNameY or 0,
	}

	self.imageFonts = {
		scoreFont = getImageFont(score_font_path),
	}

	self.sounds = {
		applause = self.loadAudio(skin_path .. "applause"),
		menuBack = self.loadAudio(skin_path .. "menuback"),
		switchScreen = self.loadAudio(skin_path .. "menuhit"),
	}

	self.images = {
		title = self:loadImageOrDefault(skin_path, "ranking-title"),
		panel = self:loadImageOrDefault(skin_path, "ranking-panel"),
		graph = self:loadImageOrDefault(skin_path, "ranking-graph"),
		menuBack = self:loadImageOrDefault(skin_path, "menu-back"),
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

	self.customConfig = love.filesystem.load(skin_path .. "ResultViewConfig.lua")
end

return OsuResultAssets
