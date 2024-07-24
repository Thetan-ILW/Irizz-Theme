local class = require("class")

---@class skibidi.AssetModel
---@operator call: skibidi.AssetModel
---@field fields table<string, skibidi.Assets>
---@field localizations table<string,{name: string, filepath: string}[]>
local AssetModel = class()

function AssetModel:new()
	self.fields = {}
	self.localizations = {}
	self:loadLocalizationLists()
end

---@param name string
---@param assets skibidi.Assets
function AssetModel:store(name, assets)
	self.fields[name] = assets
end

---@param name string
---@return skibidi.Assets?
function AssetModel:get(name)
	return self.fields[name]
end

local localization_directories = {
	irizz = "thetan/irizz/localization/",
	osu = "thetan/osu/localization/",
}

function AssetModel:loadLocalizationLists()
	for theme, dir in pairs(localization_directories) do
		---@type {name: string, filepath: string}[]
		local list = love.filesystem.load(dir .. "list.lua")()
		assert(list, theme .. " localization list not found.")

		for _, v in ipairs(list) do
			v.filepath = dir .. v.filepath
		end

		self.localizations[theme] = list
	end
end

---@param theme string
---@param name string
---@return string
function AssetModel:getLocalizationFileName(theme, name)
	for _, v in ipairs(self.localizations[theme]) do
		if v.name == name then
			return v.filepath
		end
	end

	return self.localizations[theme][1].filepath
end

return AssetModel
