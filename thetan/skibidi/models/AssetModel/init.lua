local class = require("class")

---@class skibidi.AssetModel
---@operator call: skibidi.AssetModel
---@field configModel sphere.ConfigModel
---@field fields table<string, skibidi.Assets>
---@field localizations table<string,{name: string, filepath: string}[]>
local AssetModel = class()

function AssetModel:new(config_model)
	self.configModel = config_model

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
function AssetModel:getLocalizationNames(theme)
	return self.localizations[theme]
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

function AssetModel:getOsuSkins()
	---@type string[]
	local skins = love.filesystem.getDirectoryItems("userdata/skins/")

	---@type string[]
	local osu_skin_names = {}

	for _, name in ipairs(skins) do
		---@type string
		local path = "userdata/skins/" .. name
		if love.filesystem.getInfo(path .. "/skin.ini") then
			table.insert(osu_skin_names, name)
		end
	end

	table.insert(osu_skin_names, "No skin")

	return osu_skin_names
end

function AssetModel:updateVolume()
	for _, v in pairs(self.fields) do
		v:updateVolume(self.configModel)
	end
end

return AssetModel
