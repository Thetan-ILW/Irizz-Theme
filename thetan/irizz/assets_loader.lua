local IrizzAssets = require("thetan.irizz.views.IrizzAssets")

---@param game sphere.GameController
return function(game)
	---@type skibidi.AssetModel
	local asset_model = game.assetModel
	local configs = game.configModel.configs
	local irizz = configs.irizz

	local language = irizz.language

	local assets = asset_model:get("irizz")

	local localization_filepath = asset_model:getLocalizationFileName("irizz", language)

	if not assets then
		assets = IrizzAssets(asset_model:getLocalizationFileName("irizz", "English"))
		asset_model:store("irizz", assets)
	end

	---@cast assets irizz.IrizzAssets
	assets = assets
	assets:loadLocalization(localization_filepath)
	assets:updateVolume(game.configModel)
	assets:loadColorTheme(irizz.colorTheme)

	return assets
end
