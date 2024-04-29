local defaultColorTheme = require("irizz.color_themes.Default")
local defaultLocalization = require("irizz.localization.en")
local table_util = require("table_util")
local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")

local Assets = {}

local function getItems(directory, cutExtension)
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

local function getFilePath(fileName)
	local userPath = "userdata/" .. fileName
	local internalPath = "irizz/" .. fileName

	if love.filesystem.getInfo(userPath) then
		return userPath
	end

	if love.filesystem.getInfo(internalPath) then
		return internalPath
	end

	return nil
end

local audioExt = { ".wav", ".ogg", ".mp3" }
local function getSound(fileName)
	for _, ext in ipairs(audioExt) do
		local filePath = getFilePath(fileName .. ext)

		if filePath then
			return filePath
		end
	end
end

function Assets:updateColorTheme(name, theme)
	local file = assert(getFilePath("color_themes/" .. name .. ".lua"))
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
		localization = love.filesystem.load(file)()
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

local image_format = {
	"png",
	"jpg",
	"jpeg",
	"bmp",
	"tga",
}

local function findImage(path)
	for _, format in ipairs(image_format) do
		local normal = path .. "." .. format
		local double = path .. "@2x." .. format

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
		return love.graphics.newImage(path)
	end

	return nil
end

function Assets:getOsuResultAssets(skin_path)
	skin_path = skin_path .. "/"

	local content = love.filesystem.read(skin_path .. "skin.ini")

	if not content then
		return nil
	end

	content = utf8validate(content)
	local skinini = OsuNoteSkin:parseSkinIni(content)

	local scoreFontPath = skin_path .. skinini.Fonts.ScorePrefix or skin_path .. "score"

	local t = {
		title = loadImage(skin_path .. "ranking-title"),
		panel = loadImage(skin_path .. "ranking-panel"),
		graph = loadImage(skin_path .. "ranking-graph"),
		scoreFont = getImageFont(scoreFontPath),
		scoreOverlap = skinini.Fonts.ScoreOverlap or 0,

		grade = {
			SS = loadImage(skin_path .. "ranking-X"),
			S = loadImage(skin_path .. "ranking-S"),
			A = loadImage(skin_path .. "ranking-A"),
			B = loadImage(skin_path .. "ranking-B"),
			C = loadImage(skin_path .. "ranking-C"),
			D = loadImage(skin_path .. "ranking-D"),
		},
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
	local startSounds = getItems("ui_sounds/start")

	for _, name in ipairs(startSounds) do
		local filePath = getFilePath("ui_sounds/start/" .. name)
		local sound

		if filePath ~= nil then
			sound = love.audio.newSource(filePath, "static")
			theme.sounds.start[name] = sound
			table.insert(theme.sounds.startNames, name)
		end
	end

	local gfx = love.graphics

	local function sound(name)
		local filePath = getSound(name)

		if not filePath then
			return nil
		end

		return love.audio.newSource(filePath, "static")
	end

	local t = theme.sounds
	theme.avatarImage = gfx.newImage(assert(getFilePath("avatar.png")))
	theme.gameIcon = gfx.newImage(assert(getFilePath("game_icon.png")))
	t.scrollLargeList = sound("ui_sounds/scroll_large_list")
	t.scrollSmallList = sound("ui_sounds/scroll_small_list")
	t.checkboxClick = sound("ui_sounds/checkbox_click")
	t.buttonClick = sound("ui_sounds/button_click")
	t.sliderMoved = sound("ui_sounds/slider_moved")
	t.tabButtonClick = sound("ui_sounds/tab_button_click")
	t.songSelectScreenChanged = sound("ui_sounds/song_select_screen_changed")

	theme.colorThemes = getItems("color_themes/", true)

	for _, v in ipairs(theme.colorThemes) do
		if v == config.colorTheme then
			self:updateColorTheme(config.colorTheme, theme)
			break
		end
	end

	local localizations = getItems("localization")
	theme.localizations = {}

	for _, v in ipairs(localizations) do
		local fileName = getFilePath("localization/" .. v)

		if fileName then
			local file = love.filesystem.load(fileName)()
			table.insert(theme.localizations, { name = file.language, fileName = fileName })

			if file.language == config.language then
				self:loadLocalization(file, theme)
			end
		end
	end

	local icons_path = "irizz/icons/"
	local icons = {
		modifiers = love.graphics.newImage(icons_path .. "modifiers.png"),
		filters = love.graphics.newImage(icons_path .. "filters.png"),
		noteSkins = love.graphics.newImage(icons_path .. "note_skins.png"),
		inputs = love.graphics.newImage(icons_path .. "inputs.png"),
		keyBinds = love.graphics.newImage(icons_path .. "key_binds.png"),
		multiplayer = love.graphics.newImage(icons_path .. "multiplayer.png"),
		chartEditor = love.graphics.newImage(icons_path .. "chart_editor.png"),
		retry = love.graphics.newImage(icons_path .. "retry.png"),
		watch = love.graphics.newImage(icons_path .. "watch.png"),
		submit = love.graphics.newImage(icons_path .. "submit.png"),
	}

	theme.icons = icons

	theme.resultCustomConfig = love.filesystem.load("userdata/ui/result/config.lua")
	theme.osuSkins, theme.osuSkinNames = getOsuSkins()
end

return Assets
