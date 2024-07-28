local Assets = require("thetan.skibidi.models.AssetModel.Assets")
local Localization = require("thetan.skibidi.models.AssetModel.Localization")

local colors = require("thetan.irizz.ui.colors")

local table_util = require("table_util")

---@class (exact) irizz.IrizzAssets : skibidi.Assets
---@operator call: irizz.IrizzAssets
---@field defaultsDirectory string
---@field images table<string, love.Image>
---@field sounds table<string, audio.Source>
---@field startSounds table<string, audio.Source>
---@field startSoundNames string[]
---@field localization skibidi.Localization
---@field colorThemes string[]
---@field errors string[]
local IrizzAssets = Assets + {}

IrizzAssets.defaultsDirectory = "irizz/"
IrizzAssets.startSounds = {}
IrizzAssets.startSoundNames = {}

---@param directory string
---@param cut_extension boolean
---@return string[]
local function getItems(directory, cut_extension)
	local internal = love.filesystem.getDirectoryItems("irizz/" .. directory)
	local userdata = love.filesystem.getDirectoryItems("userdata/" .. directory)

	---@type string[]
	local t = {}
	table_util.append(t, internal)
	table_util.append(t, userdata)

	if cut_extension then
		for i, v in ipairs(t) do
			t[i] = v:match("(.+)%..+$")
		end
	end

	return t
end

---@param path string
---@return love.Image
local function loadImageOrEmpty(path)
	return Assets.loadImage(path) or Assets.emptyImage()
end

function IrizzAssets:new()
	local userdata = "userdata/"
	local icons = "irizz/icons/"
	local start_sounds = "ui_sounds/start/"

	self.images = {
		gameIcon = IrizzAssets:loadImageOrDefault(userdata, "game_icon"),
		avatar = IrizzAssets:loadImageOrDefault(userdata, "avatar"),
		buttonGradient = IrizzAssets:loadImageOrDefault(userdata, "images/button_gradient"),

		modifiersIcon = loadImageOrEmpty(icons .. "modifiers.png"),
		filtersIcon = loadImageOrEmpty(icons .. "filters.png"),
		noteSkinsIcon = loadImageOrEmpty(icons .. "note_skins.png"),
		inputsIcon = loadImageOrEmpty(icons .. "inputs.png"),
		keyBindsIcon = loadImageOrEmpty(icons .. "key_binds.png"),
		multiplayerIcon = loadImageOrEmpty(icons .. "multiplayer.png"),
		chartEditorIcon = loadImageOrEmpty(icons .. "chart_editor.png"),
		retryIcon = loadImageOrEmpty(icons .. "retry.png"),
		watchIcon = loadImageOrEmpty(icons .. "watch.png"),
		submitIcon = loadImageOrEmpty(icons .. "submit.png"),
	}

	self.sounds = {
		scrollLargeList = IrizzAssets:loadAudioOrDefault("", "ui_sounds/scroll_large_list"),
		scrollSmallList = IrizzAssets:loadAudioOrDefault("", "ui_sounds/scroll_small_list"),
		checkboxClick = IrizzAssets:loadAudioOrDefault("", "ui_sounds/checkbox_click"),
		buttonClick = IrizzAssets:loadAudioOrDefault("", "ui_sounds/button_click"),
		sliderMoved = IrizzAssets:loadAudioOrDefault("", "ui_sounds/slider_moved"),
		tabButtonClick = IrizzAssets:loadAudioOrDefault("", "ui_sounds/tab_button_click"),
		songSelectScreenChanged = IrizzAssets:loadAudioOrDefault("", "ui_sounds/song_select_screen_changed"),
		pauseAmbient = IrizzAssets:loadAudioOrDefault("", "ui_sounds/pause"),
	}

	local sounds = getItems(start_sounds, true)

	for _, name in ipairs(sounds) do
		table.insert(self.startSoundNames, name)
		self.startSounds[name] = IrizzAssets:loadAudioOrDefault("", start_sounds .. name)
	end

	self.colorThemes = getItems("color_themes/", true)

	for _, v in ipairs(self.errors) do
		print(v)
	end
end

---@param config_model sphere.ConfigModel
function IrizzAssets:updateVolume(config_model)
	local configs = config_model.configs
	local settings = configs.settings
	local irizz = configs.irizz
	local a = settings.audio
	local v = a.volume

	---@type number
	local volume = irizz.uiVolume * v.master

	for _, item in pairs(self.sounds) do
		item:setVolume(volume)
	end

	for _, item in pairs(self.startSounds) do
		item:setVolume(volume)
	end
end

---@param filepath string
function IrizzAssets:loadLocalization(filepath)
	if not self.localization then
		self.localization = Localization(filepath, 1080)
		return
	end

	if self.localization.currentFilePath ~= filepath then
		self.localization:loadFile(filepath)
	end
end

---@param name string
function IrizzAssets:loadColorTheme(name)
	local custom = love.filesystem.load("userdata/color_themes/" .. name .. ".lua")
	local internal = love.filesystem.load("irizz/color_themes/" .. name .. ".lua")

	local file = custom or internal
	assert(file)

	---@type table
	local color_theme = file()

	for k, v in pairs(color_theme) do
		table_util.copy(v, colors[k])
	end
end

return IrizzAssets
