local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")

local audio = require("audio")

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer?
return function(assets, view)
	local text, font = assets.localization:get("settings")
	assert(text and font)

	local settings = view.game.configModel.configs.settings
	local a = settings.audio
	local g = settings.gameplay
	local m = settings.miscellaneous
	local vol = a.volume

	local c = GroupContainer(text.audio, assets, font, assets.images.audioTab)

	----- there is no log volume type in osu
	a.volumeType = "linear"

	Elements.assets = assets
	Elements.currentContainer = c
	local checkbox = Elements.checkbox
	local slider = Elements.slider
	local button = Elements.button

	--------------- VOLUME ---------------
	c:createGroup("volume", text.volume)
	Elements.currentGroup = "volume"

	local linear_volume = { min = 0, max = 1, increment = 0.01 }

	Elements.sliderPixelWidth = 340

	local volume_format = function(v)
		return ("%i%%"):format(v * 100)
	end

	slider(text.master, nil, nil, function()
		return vol.master, linear_volume
	end, function(v)
		vol.master = v
		assets:updateVolume(view.game.configModel)
	end, volume_format)

	slider(text.music, nil, nil, function()
		return vol.music, linear_volume
	end, function(v)
		vol.music = v
		assets:updateVolume(view.game.configModel)
	end, volume_format)

	slider(text.effect, nil, nil, function()
		return vol.effects, linear_volume
	end, function(v)
		vol.effects = v
		assets:updateVolume(view.game.configModel)
	end, volume_format)

	Elements.sliderPixelWidth = nil

	local mode = a.mode
	local pitch = mode.primary == "bass_sample" and true or false

	checkbox(text.rateChangesPitch, false, text.rateChangesPitchTip, function()
		pitch = mode.primary == "bass_sample" and true or false
		return pitch
	end, function()
		local audio_mode = not pitch and "bass_sample" or "bass_fx_tempo"
		mode.primary = audio_mode
		mode.secondary = audio_mode
	end)

	checkbox(text.autoKeySound, false, text.autoKeySoundTip, function()
		return g.autoKeySound
	end, function()
		g.autoKeySound = not g.autoKeySound
	end)

	checkbox(text.midiConstantVolume, false, nil, function()
		return a.midi.constantVolume
	end, function()
		a.midi.constantVolume = not a.midi.constantVolume
	end)

	checkbox(text.muteOnUnfocus, false, nil, function()
		return a.muteOnUnfocus
	end, function()
		a.muteOnUnfocus = not a.muteOnUnfocus
	end)

	c:createGroup("device", text.device)
	Elements.currentGroup = "device"

	Elements.sliderPixelWidth = 290

	local period_and_buffer = { min = 1, max = 50, increment = 1 }
	slider(text.updatePeriod, 10, nil, function()
		return a.device.period, period_and_buffer
	end, function(v)
		a.device.period = v
	end, function(v)
		return ("%dms"):format(v)
	end)

	slider(text.bufferLength, 40, nil, function()
		return a.device.buffer, period_and_buffer
	end, function(v)
		a.device.buffer = v
	end, function(v)
		return ("%dms"):format(v)
	end)

	slider(text.adjustRate, 0.1, nil, function()
		return a.adjustRate, { min = 0, max = 1, increment = 0.01 }
	end, function(v)
		a.adjustRate = v
	end, function(v)
		return ("%0.02f"):format(v)
	end)

	Elements.sliderPixelWidth = nil

	button(text.apply, function()
		audio.setDevicePeriod(a.device.period)
		audio.setDeviceBuffer(a.device.buffer)
		audio.reinit()
	end)
	button(text.reset, function()
		a.device.period = audio.default_dev_period
		a.device.buffer = audio.default_dev_buffer
		audio.setDevicePeriod(a.device.period)
		audio.setDeviceBuffer(a.device.buffer)
		audio.reinit()
	end)

	c:removeEmptyGroups()

	if c.isEmpty then
		return nil
	end

	return c
end
