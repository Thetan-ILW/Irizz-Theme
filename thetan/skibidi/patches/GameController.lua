local ActionModel = require("thetan.skibidi.models.ActionModel")
local AssetModel = require("thetan.skibidi.models.AssetModel")

local PlayerProfileModel = require("thetan.skibidi.models.PlayerProfileModel")
local GameController = require("sphere.controllers.GameController")

local base_new = GameController.new
local base_load = GameController.load

function GameController:new()
	base_new(self)

	self.actionModel = ActionModel(self.persistence.configModel)
	self.assetModel = AssetModel(self.persistence.configModel)

	self.playerProfileModel = PlayerProfileModel(self)
	self.gameplayController.playerProfileModel = self.playerProfileModel
end

function GameController:load()
	base_load(self)

	self.actionModel:load()
end
