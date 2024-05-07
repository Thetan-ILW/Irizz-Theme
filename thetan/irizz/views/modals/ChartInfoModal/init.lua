local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.ChartInfoModal.ViewConfig")

local Theme = require("thetan.irizz.views.Theme")
local Text = Theme.textChartInfo

local ChartInfoModal = Modal + {}

ChartInfoModal.name = "ChartInfoModal"
ChartInfoModal.viewConfig = ViewConfig()
ChartInfoModal.infoCache = {}
ChartInfoModal.ssrCache = ""

local orderedInfo = {
	{ "artist", Text.artist },
	{ "title", Text.title },
	{ "name", Text.chartName },
	{ "tempo", Text.bpm },
	{ "tags", Text.tags },
	{ "source", Text.source },
	{ "format", Text.chartFormat },
	{ "set_name", Text.setName },
	{ "real_dir", Text.path },
	{ "audio_path", Text.audioPath },
	{ "background_path", Text.backgroundPath },
	{ "chartdiff_inputmode", Text.mode },
	{ "chartfile_name", Text.chartFileName },
	{ "hash", Text.hash },
}

function ChartInfoModal:new(game)
	self.game = game
end

function ChartInfoModal:onShow()
	local items = self.game.selectModel.noteChartLibrary.items
	local index = self.game.selectModel.chartview_index
	local timeRateModel = self.game.timeRateModel

	self.infoCache = {}
	self.ssrCache = ""

	local item = items[index]

	if not item then
		return
	end

	for _, field in ipairs(orderedInfo) do
		table.insert(self.infoCache, ("%s: %s"):format(field[2], tostring(item[field[1]])))
	end

	if not item.msd_diff_data then
		return
	end

	local ssr = Theme.getMsdFromData(item.msd_diff_data, timeRateModel:get())

	if not ssr then
		return
	end

	local ssrNames = Theme.getSsrPatternNames()

	for _, name in ipairs(ssrNames) do
		self.ssrCache = self.ssrCache .. ("%s: %0.02f\n"):format(name, ssr[name])
	end
end

return ChartInfoModal
