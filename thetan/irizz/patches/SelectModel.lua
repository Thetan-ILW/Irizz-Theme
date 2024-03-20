local modulePatcher = require("ModulePatcher")
local path_util = require("path_util")

modulePatcher:insert("sphere.models.SelectModel", "getAudioPathPreview", function(_self)
	local chartview = _self.chartview
	if not chartview then
		return
	end

	local mode = "absolute"

	local audio_path = chartview.audio_path
	if not audio_path or audio_path == "" then
		return path_util.join(chartview.real_dir, "preview.ogg"), 0, mode
	end

	local full_path = path_util.join(chartview.real_dir, audio_path)
	local preview_time = chartview.preview_time

	if preview_time < 3 and chartview.format == "osu" then
		mode = "relative"
		preview_time = 0.4
	end

	return full_path, preview_time, mode
end)
