local class = require("class")

---@class skibidi.AssetModel
---@operator call: skibidi.AssetModel
---@field fields table<string, skibidi.Assets>
local AssetModel = class()

function AssetModel:new()
	self.fields = {}
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

return AssetModel
