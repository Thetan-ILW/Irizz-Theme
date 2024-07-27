local Modal = require("thetan.irizz.views.modals.Modal")
local ViewConfig = require("thetan.irizz.views.modals.ChartInfoModal.ViewConfig")

local msd_util = require("thetan.skibidi.msd_util")

local ChartInfoModal = Modal + {}

ChartInfoModal.name = "ChartInfoModal"
ChartInfoModal.infoCache = {}
ChartInfoModal.ssrCache = ""

function ChartInfoModal:new(game)
	self.game = game
	self.assets = game.assetModel:get("irizz")
	self.viewConfig = ViewConfig(self.assets)
end

function ChartInfoModal:onShow()
	local text = self.assets.localization.textGroups.chartInfoModal

	local orderedInfo = {
		{ "artist", text.artist },
		{ "title", text.title },
		{ "name", text.chartName },
		{ "tempo", text.bpm },
		{ "tags", text.tags },
		{ "source", text.source },
		{ "format", text.chartFormat },
		{ "set_name", text.setName },
		{ "real_dir", text.path },
		{ "audio_path", text.audioPath },
		{ "background_path", text.backgroundPath },
		{ "chartdiff_inputmode", text.mode },
		{ "chartfile_name", text.chartFileName },
		{ "hash", text.hash },
	}

	local items = self.game.selectModel.noteChartLibrary.items
	local index = self.game.selectModel.chartview_index
	local time_rate_model = self.game.timeRateModel

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

	local ssr = msd_util.getMsdFromData(item.msd_diff_data, time_rate_model:get())

	if not ssr then
		return
	end

	local ssrNames = msd_util.getSsrPatternNames()

	for _, name in ipairs(ssrNames) do
		self.ssrCache = self.ssrCache .. ("%s: %0.02f\n"):format(name, ssr[name])
	end
end

return ChartInfoModal
