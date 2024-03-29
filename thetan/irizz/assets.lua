local defaultColorTheme = require("irizz.color_themes.Default")
local localization = require("irizz.localization.en")
local table_util = require("table_util")

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


function Assets:updateColorTheme(name)
	local file = assert(getFilePath("color_themes/" .. name .. ".lua"))
	local colorTheme = love.filesystem.load(file)()

	for k, v in pairs(colorTheme) do
		table_util.copy(v, self[k])
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

function Assets:init(theme)
	table_util.copy(localization, theme)
	table_util.copy(defaultColorTheme, theme)
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
			self:updateColorTheme(config.colorTheme)
			break
		end
	end
end

return Assets
