local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")

local math_util = require("math_util")

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer?
return function(assets, view)
	local font = assets.localization.fontGroups.settings

	local settings = view.game.configModel.configs.settings
	local a = settings.audio
	local g = settings.gameplay
	local vol = a.volume

	local c = GroupContainer("AUDIO", assets, font, assets.images.audioTab)

	----- there is no log volume type in osu
	a.volumeType = "linear"

	Elements.assets = assets
	Elements.currentContainer = c
	local checkbox = Elements.checkbox
	local slider = Elements.slider

	--------------- AUDIO ---------------
	c:createGroup("volume", "VOLUME")
	Elements.currentGroup = "volume"

	local linear_volume = { min = 0, max = 1, increment = 0.01 }

	Elements.sliderPixelWidth = 340

	slider("Master:", nil, nil, function()
		return vol.master, linear_volume
	end, function(v)
		vol.master = v
		assets:updateVolume(view.game.configModel)
	end)

	slider("Music:", nil, nil, function()
		return vol.music, linear_volume
	end, function(v)
		vol.music = v
		assets:updateVolume(view.game.configModel)
	end)

	slider("Effect:", nil, nil, function()
		return vol.effects, linear_volume
	end, function(v)
		vol.effects = v
		assets:updateVolume(view.game.configModel)
	end)

	Elements.sliderPixelWidth = nil

	local mode = a.mode
	local pitch = mode.primary == "bass_sample" and true or false

	checkbox("Rate changes pitch", false, nil, function()
		pitch = mode.primary == "bass_sample" and true or false
		return pitch
	end, function()
		local audio_mode = not pitch and "bass_sample" or "bass_fx_tempo"
		mode.primary = audio_mode
		mode.secondary = audio_mode
	end)

	c:removeEmptyGroups()

	if c.isEmpty then
		return nil
	end

	return c
end
