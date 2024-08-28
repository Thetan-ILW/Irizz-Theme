local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer
return function(assets, view)
	local font = assets.localization.fontGroups.settings

	local settings = view.game.configModel.configs.settings
	local a = settings.audio
	local g = settings.gameplay

	local c = GroupContainer("AUDIO", font)

	Elements.assets = assets
	Elements.currentContainer = c
	local checkbox = Elements.checkbox

	--------------- AUDIO ---------------
	c:createGroup("volume", "VOLUME")
	Elements.currentGroup = "volume"

	local mode = a.mode
	local pitch = mode.primary == "bass_sample" and true or false

	checkbox("Rate changes pitch", function()
		pitch = mode.primary == "bass_sample" and true or false
		return pitch
	end, function()
		local audio_mode = not pitch and "bass_sample" or "bass_fx_tempo"
		mode.primary = audio_mode
		mode.secondary = audio_mode
	end)

	return c
end
