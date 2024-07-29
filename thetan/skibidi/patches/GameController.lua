local ActionModel = require("thetan.skibidi.models.ActionModel")
local AssetModel = require("thetan.skibidi.models.AssetModel")

local GameController = require("sphere.controllers.GameController")

local base_new = GameController.new
local base_load = GameController.load

function GameController:new()
	base_new(self)

	self.actionModel = ActionModel(self.persistence.configModel)
	self.assetModel = AssetModel(self.persistence.configModel)
end

function GameController:load()
	base_load(self)

	self.actionModel:load()
end
