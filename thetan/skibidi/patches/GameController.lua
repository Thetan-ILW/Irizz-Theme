local ActionModel = require("thetan.skibidi.models.ActionModel")
local AssetModel = require("thetan.skibidi.models.AssetModel")
local OsuApiModel = require("thetan.skibidi.models.OsuApi")

local GameController = require("sphere.controllers.GameController")

local base_new = GameController.new
local base_load = GameController.load

function GameController:new()
	base_new(self)

	self.actionModel = ActionModel(self.persistence.configModel)
	self.assetModel = AssetModel(self.persistence.configModel)
	self.osuApi = OsuApiModel(self)
end

function GameController:load()
	base_load(self)

	table.insert(self.selectModel.scoreLibrary.scoreSources, "osu")

	self.actionModel:load()
	self.osuApi:load()
end
