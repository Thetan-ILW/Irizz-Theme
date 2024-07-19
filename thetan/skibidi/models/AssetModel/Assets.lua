local class = require("class")

local audio = require("audio")
local gfx_util = require("gfx_util")

---@class skibidi.Assets
---@operator call: skibidi.Assets
---@field defaultsDirectory string
---@field images table<string, love.Image>
---@field sounds table<string, audio.Source?>
---@field params table<string, number|string|boolean>
---@field errors string[]
local Assets = class()

Assets.errors = {}

---@type string
local source_directory = love.filesystem.getSource()

local audio_extensions = { ".wav", ".ogg", ".mp3" }
local image_extensions = { ".png", ".jpg", ".jpeg", ".bmp", ".tga" }

---@param path string
---@return string?
function Assets.findImage(path)
	for _, format in ipairs(image_extensions) do
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
end

---@param path string
---@return string?
function Assets.findAudio(path)
	if not path then
		return
	end

	for _, format in ipairs(audio_extensions) do
		local audio_path = path .. format

		if love.filesystem.getInfo(audio_path) then
			return audio_path
		end
	end
end

---@param path string
---@return love.Image?
function Assets.loadImage(path)
	path = Assets.findImage(path)

	if path then
		local success, result = pcall(love.graphics.newImage, path)

		if success then
			return result
		end

		table.insert(Assets.errors, ("Failed to load image %s"):format(path))
	end
end

---@param path string
---@return audio.Source?
function Assets.loadAudio(path)
	path = Assets.findAudio(path)

	if path then
		path = source_directory .. "/" .. path
		local success, result = pcall(audio.newFileSource, path)

		if success then
			return result
		end

		table.insert(Assets.errors, ("Failed to load sound %s"):format(path))
	end
end

function Assets:loadImageOrDefault(directory, name)
	local image = Assets.loadImage(directory .. name)

	if image then
		return image
	end

	image = Assets.loadImage(self.defaultsDirectory .. name)

	if image then
		return image
	end

	return gfx_util.newPixel(0, 0, 0, 0)
end

---@param config_model sphere.ConfigModel
function Assets:updateVolume(config_model)
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
end

return Assets
