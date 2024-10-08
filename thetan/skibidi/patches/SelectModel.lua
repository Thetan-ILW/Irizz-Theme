local SelectModel = require("sphere.models.SelectModel")

local path_util = require("path_util")

local randomHistory = {}

function SelectModel:getAudioPathPreview()
	local chartview = self.chartview
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

	if preview_time < 3 then
		mode = "relative"
		preview_time = 0.4
	end

	return full_path, preview_time, mode
end

function SelectModel:scrollRandom()
	local items = self.noteChartSetLibrary.items

	local destination = math.random(1, #items)
	local currentChart = self.chartview_set_index
	table.insert(randomHistory, currentChart) -- <<<

	self:scrollNoteChartSet(nil, destination)
end

function SelectModel:undoRandom()
	local destination = table.remove(randomHistory)

	if destination == nil then
		return
	end

	self:scrollNoteChartSet(nil, destination)
end
