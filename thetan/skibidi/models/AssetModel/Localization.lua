local class = require("class")
local table_util = require("table_util")

---@class skibidi.Localization
---@operator call: skibidi.Localization
---@field fontScale number
---@field fontGroups table<string, table<string, love.Font>>
---@field textGroups table<string, table<string, string>>
---@field currentFile table
---@field fontInstances table<string, table<string, love.Font>>
local Localization = class()

Localization.fontScale = 1
Localization.fontGroups = {}
Localization.textGroups = {}

---@param filepath string
function Localization:new(filepath, font_scale)
	self.fontScale = font_scale
	self:loadFile(filepath)
end

---@param filepath string
function Localization:loadFile(filepath)
	self.currentFile = love.filesystem.load(filepath)()
	self:setFonts()
	self:setText()
end

function Localization:updateScale(font_scale)
	if self.fontScale == font_scale then
		return
	end

	self.fontScale = font_scale
	self:setFonts()
end

Localization.fontInstances = {}

---@param name string
---@param size number
---@return love.Font
function Localization:loadFont(name, size)
	local size_str = tostring(size * self.fontScale)

	if self.fontInstances[name] and self.fontInstances[name][size_str] then
		return self.fontInstances[name][size_str]
	end

	---@type string
	local filename = self.currentFile.fontFiles[name]
	local font = love.graphics.newFont(filename, size * self.fontScale)

	self.fontInstances[name] = self.fontInstances[name] or {}
	self.fontInstances[name][size_str] = font

	return font
end

function Localization:setFonts()
	---@type table<string, table>
	local fontGroups = self.currentFile.fontGroups

	for group_name, group in pairs(fontGroups) do
		---@cast group table<string, table>

		---@type table<string, love.Font>
		local fonts = {}

		for name, params in pairs(group) do
			local font = self:loadFont(params[1], params[2])

			if params[3] then
				font:setFallbacks(self:loadFont(params[3], params[2]))
			end

			font:setFilter("nearest", "nearest")

			fonts[name] = font
		end

		self.fontGroups[group_name] = self.fontGroups[group_name] or {}
		table_util.copy(fonts, self.fontGroups[group_name])
	end
end

function Localization:setText()
	---@type table<string, table<string, string>>
	local textGroups = self.currentFile.textGroups

	for group_name, group in pairs(textGroups) do
		self.textGroups[group_name] = self.textGroups[group_name] or {}
		table_util.copy(group, self.textGroups[group_name])
	end
end

return Localization
