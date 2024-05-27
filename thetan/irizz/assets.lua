local defaultColorTheme = require("irizz.color_themes.Default")
local defaultLocalization = require("irizz.localization.en")
local table_util = require("table_util")
local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")
local audio = require("audio")

local Assets = {}

local gfx = love.graphics
local audioExt = { ".wav", ".ogg", ".mp3" }
local imageExt = { ".png", ".jpg", ".jpeg", ".bmp", ".tga" }

local function getIrizzItems(directory, cutExtension)
	local internal = love.filesystem.getDirectoryItems("irizz/" .. directory)
	local userdata = love.filesystem.getDirectoryItems("userdata/" .. directory)

	local t = {}
	table_util.append(t, internal)
	table_util.append(t, userdata)

	if cutExtension then
		for i, v in ipairs(t) do
			t[i] = v:match("(.+)%..+$")
		end
	end

	return t
end

local function getCustomOrInternal(path)
	local user_path = "userdata/" .. path
	local internal_path = "irizz/" .. path

	if love.filesystem.getInfo(user_path) then
		return user_path, nil
	end

	if love.filesystem.getInfo(internal_path) then
		return nil, internal_path
	end
end

local function getIrizzFile(file_name, extensions)
	local internal

	for _, ext in ipairs(extensions) do
		local user_path, internal_path = getCustomOrInternal(file_name .. ext)

		if user_path then
			return user_path
		end

		internal = internal_path or internal
	end

	return internal
end

---@param sound_path string
---@return audio.SoundData
local function getSoundData(sound_path)
	local file_data = love.filesystem.newFileData(sound_path)
	return audio.SoundData(file_data:getFFIPointer(), file_data:getSize())
end

---@param file_name string
---@return audio.Source?
local function getIrizzSound(file_name)
	local file_path = getIrizzFile(file_name, audioExt)

	if file_path then
		return audio.newSource(getSoundData(file_path))
	end
end

---@param file_name string
---@return love.Image?
local function getIrizzImage(file_name)
	local file_path = getIrizzFile(file_name, imageExt)

	if file_path then
		return gfx.newImage(file_path)
	end
end

function Assets:updateColorTheme(name, theme)
	local user, interal = getCustomOrInternal("color_themes/" .. name .. ".lua")
	local file = user or interal
	assert(file)

	local colorTheme = love.filesystem.load(file)()

	for k, v in pairs(colorTheme) do
		table_util.copy(v, theme[k])
	end
end

---@param list table?
---@return string?
local function getFirstFile(list)
	if not list then
		return
	end
	for _, path in ipairs(list) do
		if love.filesystem.getInfo(path) then
			return path
		end
	end
end

local instances = {}

---@param fontFamilyList table
---@param filename string
---@param size number
---@return love.Font
function Assets:getFont(fontFamilyList, filename, size)
	if instances[filename] and instances[filename][size] then
		return instances[filename][size]
	end
	local f = fontFamilyList[filename]

	local font = love.graphics.newFont(getFirstFile(f) or filename, size)
	instances[filename] = instances[filename] or {}
	instances[filename][size] = font
	if f and f.height then
		font:setLineHeight(f.height)
	end
	return font
end

function Assets:loadLocalization(file, theme)
	local localization = file

	if type(file) == "string" then
		local user, internal = getCustomOrInternal("localization/" .. file)
		if not user and not internal then
			return
		end

		localization = love.filesystem.load(user or internal)()
	end

	for groupName, group in pairs(localization) do
		if groupName == "fonts" or groupName == "fontFamilyList" or groupName == "language" then
			theme[groupName] = group
			goto continue
		end

		for k, v in pairs(group) do
			theme[groupName][k] = v
		end

		::continue::
	end
end

function Assets:init(theme)
	table_util.copy(defaultLocalization, theme)
	table_util.copy(defaultColorTheme, theme)
end

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

local function findImage(path)
	for _, format in ipairs(imageExt) do
		local normal = path .. format
		local double = path .. "@2x" .. format

		if love.filesystem.getInfo(double) then
			return double
		end

		if love.filesystem.getInfo(normal) then
			return normal
		end

		if love.filesystem.getInfo(double:lower()) then
			return double:lower()
		end

		if love.filesystem.getInfo(normal:lower()) then
			return normal:lower()
		end
	end

	return nil
end

local function findAudio(path)
	for _, format in ipairs(audioExt) do
		local audio_path = path .. format

		if love.filesystem.getInfo(audio_path) then
			return audio_path
		end
	end
end

local function getImageFont(group)
	local font = {}

	for _, v in ipairs(characters) do
		local file = findImage(("%s-%s"):format(group, v))

		if file then
			local key = char_alias[v] and char_alias[v] or v
			font[key] = file
		end
	end

	return font
end

local function loadImage(path)
	path = findImage(path)

	if path then
		return gfx.newImage(path)
	end

	return nil
end

local function loadAudio(path)
	local source = love.filesystem.getSource()
	path = findAudio(path)

	if path then
		return audio.newFileSource(source .. "/" .. path)
	end
end

function Assets:getOsuResultAssets(skin_path)
	skin_path = skin_path .. "/"

	local content = love.filesystem.read(skin_path .. "skin.ini")

	if not content then
		return nil
	end

	content = utf8validate(content)
	local skinini = OsuNoteSkin:parseSkinIni(content)

	local score_font_path = skin_path .. skinini.Fonts.ScorePrefix or skin_path .. "score"

	local t = {
		title = loadImage(skin_path .. "ranking-title"),
		panel = loadImage(skin_path .. "ranking-panel"),
		graph = loadImage(skin_path .. "ranking-graph"),
		menuBack = loadImage(skin_path .. "menu-back"),
		maxCombo = loadImage(skin_path .. "ranking-maxcombo"),
		accuracy = loadImage(skin_path .. "ranking-accuracy"),
		replay = loadImage(skin_path .. "pause-replay"),
		scoreFont = getImageFont(score_font_path),
		scoreOverlap = skinini.Fonts.ScoreOverlap or 0,
		accuracyNameX = skinini.Fonts.accuracyNameX or 0,
		accuracyNameY = skinini.Fonts.accuracyNameY or 0,

		judge = {
			marvelous = loadImage(skin_path .. "mania-hit300g"),
			perfect = loadImage(skin_path .. "mania-hit300"),
			great = loadImage(skin_path .. "mania-hit200"),
			good = loadImage(skin_path .. "mania-hit100"),
			bad = loadImage(skin_path .. "mania-hit50"),
			miss = loadImage(skin_path .. "mania-hit0"),
		},

		grade = {
			SS = loadImage(skin_path .. "ranking-X"),
			S = loadImage(skin_path .. "ranking-S"),
			A = loadImage(skin_path .. "ranking-A"),
			B = loadImage(skin_path .. "ranking-B"),
			C = loadImage(skin_path .. "ranking-C"),
			D = loadImage(skin_path .. "ranking-D"),
		},
		modifiers = {
			noLongNote = loadImage(skin_path .. "selection-mod-nolongnote"),
			mirror = loadImage(skin_path .. "selection-mod-mirror"),
			random = loadImage(skin_path .. "selection-mod-random"),
			doubleTime = loadImage(skin_path .. "selection-mod-doubletime"),
			halfTime = loadImage(skin_path .. "selection-mod-halftime"),
			autoPlay = loadImage(skin_path .. "selection-mod-autoplay"),
			automap4 = loadImage(skin_path .. "selection-mod-key4"),
			automap5 = loadImage(skin_path .. "selection-mod-key5"),
			automap6 = loadImage(skin_path .. "selection-mod-key6"),
			automap7 = loadImage(skin_path .. "selection-mod-key7"),
			automap8 = loadImage(skin_path .. "selection-mod-key8"),
			automap9 = loadImage(skin_path .. "selection-mod-key9"),
			automap10 = loadImage(skin_path .. "selection-mod-key10"),
		},

		sounds = {
			applause = loadAudio(skin_path .. "applause"),
			menuBack = loadAudio(skin_path .. "menuback"),
			switchScreen = loadAudio(skin_path .. "menuhit"),
		},

		customConfig = love.filesystem.load(skin_path .. "ResultViewConfig.lua"),
	}

	return t
end

local function getOsuSkins()
	local skins = love.filesystem.getDirectoryItems("userdata/skins/")

	local osu_skins = {}
	local osu_skin_names = {}

	for _, name in ipairs(skins) do
		local path = "userdata/skins/" .. name
		if love.filesystem.getInfo(path .. "/skin.ini") then
			osu_skins[name] = path
			table.insert(osu_skin_names, name)
		end
	end

	return osu_skins, osu_skin_names
end

function Assets:get(config, theme)
	local startSounds = getIrizzItems("ui_sounds/start", true)

	for _, name in ipairs(startSounds) do
		local sound = getIrizzSound("ui_sounds/start/" .. name)

		if sound ~= nil then
			theme.sounds.start[name] = sound
			table.insert(theme.sounds.startNames, name)
		end
	end

	local t = theme.sounds
	theme.avatarImage = getIrizzImage("avatar")
	theme.gameIcon = getIrizzImage("game_icon")
	t.scrollLargeList = getIrizzSound("ui_sounds/scroll_large_list")
	t.scrollSmallList = getIrizzSound("ui_sounds/scroll_small_list")
	t.checkboxClick = getIrizzSound("ui_sounds/checkbox_click")
	t.buttonClick = getIrizzSound("ui_sounds/button_click")
	t.sliderMoved = getIrizzSound("ui_sounds/slider_moved")
	t.tabButtonClick = getIrizzSound("ui_sounds/tab_button_click")
	t.songSelectScreenChanged = getIrizzSound("ui_sounds/song_select_screen_changed")

	theme.colorThemes = getIrizzItems("color_themes/", true)

	for _, v in ipairs(theme.colorThemes) do
		if v == config.colorTheme then
			self:updateColorTheme(config.colorTheme, theme)
			break
		end
	end

	local localizations = love.filesystem.getDirectoryItems("irizz/localization")
	theme.localizations = {}

	for _, file_name in ipairs(localizations) do
		if file_name then
			local file = love.filesystem.load("irizz/localization/" .. file_name)()
			table.insert(theme.localizations, { name = file.language, fileName = file_name })

			if file.language == config.language then
				self:loadLocalization(file, theme)
			end
		end
	end

	local icons_path = "irizz/icons/"
	local icons = {
		modifiers = gfx.newImage(icons_path .. "modifiers.png"),
		filters = gfx.newImage(icons_path .. "filters.png"),
		noteSkins = gfx.newImage(icons_path .. "note_skins.png"),
		inputs = gfx.newImage(icons_path .. "inputs.png"),
		keyBinds = gfx.newImage(icons_path .. "key_binds.png"),
		multiplayer = gfx.newImage(icons_path .. "multiplayer.png"),
		chartEditor = gfx.newImage(icons_path .. "chart_editor.png"),
		retry = gfx.newImage(icons_path .. "retry.png"),
		watch = gfx.newImage(icons_path .. "watch.png"),
		submit = gfx.newImage(icons_path .. "submit.png"),
	}

	theme.icons = icons

	theme.resultCustomConfig = love.filesystem.load("userdata/ui/result/config.lua")
	theme.osuSkins, theme.osuSkinNames = getOsuSkins()
end

return Assets
