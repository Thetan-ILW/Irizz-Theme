local class = require("class")
local thread = require("thread")
local gfx_util = require("gfx_util")
local flux = require("flux")
local delay = require("delay")

---@class sphere.BackgroundModel
---@operator call: sphere.BackgroundModel
local BackgroundModel = class()

BackgroundModel.alpha = 0

local defaultBackgroundsPath = "userdata/backgrounds"

function BackgroundModel:load()
	self.path = ""

	self.emptyImage = gfx_util.newPixel(0.25, 0.25, 0.25, 1)
	self.images = { self.emptyImage }

	local dir = love.filesystem.getDirectoryItems(defaultBackgroundsPath)

	if not dir or #dir == 0 then
		return
	end

	self.defaultImages = {}
	for _, item in ipairs(dir) do
		local path = defaultBackgroundsPath .. "/" .. item
		local status, imageData = pcall(love.image.newImageData, path)

		if status then
			local image = love.graphics.newImage(imageData)
			table.insert(self.defaultImages, image)
		end
	end
end

function BackgroundModel:getStepmaniaBackground(chart_path, background_name)
	local fs = love.filesystem

	local getComparable = function(file_name)
		file_name = file_name:lower()

		if not file_name:find("%.") then
			return file_name
		end

		return file_name:match("(.+)%..+")
	end

	local isImage = function(file_name)
		local imageFormats = { ".jpg", ".jpeg", ".png", ".bmp", ".tga" }
		local fileExtension = file_name:match("^.+(%..+)$")

		for _, format in ipairs(imageFormats) do
			if format == fileExtension then
				return true
			end
		end

		return false
	end

	local exists = fs.getInfo(chart_path .. "/" .. background_name)

	if background_name ~= "" and exists then
		return background_name
	end

	local dirFiles = fs.getDirectoryItems(chart_path)
	local possibleNames = { "background", "bg" }

	if background_name ~= "" then
		table.insert(possibleNames, 1, getComparable(background_name))
	end

	for _, itemName in ipairs(dirFiles) do
		local comparable = getComparable(itemName)

		for _, name in ipairs(possibleNames) do
			if comparable:find(name) then
				if isImage(itemName) then
					return itemName
				end
			end
		end
	end
end

function BackgroundModel:findImageOrDefault()
	if self.chartview.format == "sm" then
		local image = self:getStepmaniaBackground(self.chartview.location_dir, self.path)

		if image then
			return self:loadImage(self.chartview.location_dir .. "/" .. image)
		end
	end

	if not self.defaultImages then
		return self.emptyImage
	end

	local randomIndex = love.math.random(#self.defaultImages)
	return self.defaultImages[randomIndex]
end

---@param chartview table?
function BackgroundModel:setBackgroundPath(chartview)
	if not chartview then
		return
	end

	local background_path = chartview.location_dir .. "/" .. (chartview.background_path or "")

	if chartview.format == "sm" then
		if not self.chartview or (self.chartview.location_dir ~= chartview.location_dir) then
			self.chartview = chartview
			self:loadBackgroundDebounce(chartview.background_path)
		end
		return
	end

	if self.path ~= background_path then
		self.chartview = chartview
		self:loadBackgroundDebounce(background_path)
	end
end

function BackgroundModel:update()
	if #self.images > 1 then
		if self.alpha == 1 then
			table.remove(self.images, 1)
			self.alpha = 0
		elseif self.alpha == 0 then
			flux.to(self, 0.25, { alpha = 1 }):ease("quadinout")
		end
	end
end

---@param image love.Image
function BackgroundModel:setBackground(image)
	local layer = math.min(#self.images + 1, 3)
	self.images[layer] = image
	if layer == 2 then
		self.alpha = 0
	end
end

---@param path string?
function BackgroundModel:loadBackgroundDebounce(path)
	self.path = path or self.path
	delay.debounce(self, "loadDebounce", 0.1, self.loadBackground, self)
end

function BackgroundModel:loadBackground()
	local path = self.path
	if not path then
		self:setBackground(self:findImageOrDefault())
		return
	end

	if not path:find("^http") then
		local info = love.filesystem.getInfo(path)
		if not info or info.type == "directory" then
			self:setBackground(self:findImageOrDefault())
			return
		end
	end

	local image
	if path:find("%.ojn$") then
		image = self:loadImage(path, "ojn")
	elseif path:find("^http") then
		image = self:loadImage(path, "http")
	elseif path:find("%.mid$") then
		image = self:loadImage("resources/midi/background.jpg")
	else
		image = self:loadImage(path)
	end

	if path ~= self.path then
		self:loadBackground()
		return
	end

	if image then
		self:setBackground(image)
		return
	end

	self:setBackground(self.emptyImage)
end

local loadImage = thread.async(function(path)
	require("love.filesystem")
	require("love.image")

	local info = love.filesystem.getInfo(path)
	if not info then
		return
	end

	local status, imageData = pcall(love.image.newImageData, path)
	if status then
		return imageData
	end
end)

local loadOJN = thread.async(function(path)
	require("love.filesystem")
	require("love.image")
	local OJN = require("o2jam.OJN")

	local content = love.filesystem.read(path)
	if not content then
		return
	end

	local ojn = OJN(content)
	if ojn.cover == "" then
		return
	end

	local fileData = love.filesystem.newFileData(ojn.cover, "cover")
	local status, imageData = pcall(love.image.newImageData, fileData)
	if status then
		return imageData
	end
end)

local loadHttp = thread.async(function(url)
	local http = require("http")
	local body = http.request(url)
	if not body then
		return
	end

	require("love.filesystem")
	require("love.image")
	local fileData = love.filesystem.newFileData(body, "cover")
	local status, imageData = pcall(love.image.newImageData, fileData)
	if status then
		return imageData
	end
end)

---@param path string
---@param type string?
---@return love.Image?
function BackgroundModel:loadImage(path, type)
	local imageData
	if type == "ojn" then
		imageData = loadOJN(path)
	elseif type == "http" then
		imageData = loadHttp(path)
	else
		imageData = loadImage(path)
	end
	if not imageData then
		return
	end
	return love.graphics.newImage(imageData)
end

return BackgroundModel
