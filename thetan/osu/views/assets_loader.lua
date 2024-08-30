local OsuAssets = require("thetan.osu.OsuAssets")

---@param game sphere.GameController
return function(game)
	---@type skibidi.AssetModel
	local asset_model = game.assetModel
	local configs = game.configModel.configs
	local osu = configs.osu_ui

	---@type string
	local language = osu.language

	---@type string
	local skin_path = ("userdata/skins/%s/"):format(osu.skin)

	---@type skibidi.Assets?
	local assets = asset_model:get("osu")

	if not assets or (assets and assets.skinPath ~= skin_path) then
		local default_localization = asset_model:getLocalizationFileName("osu", "English")
		assets = OsuAssets(skin_path, default_localization)
		asset_model:store("osu", assets)
	end

	---@cast assets osu.OsuAssets
	assets = assets
	assets:updateVolume(game.configModel)

	return assets
end
