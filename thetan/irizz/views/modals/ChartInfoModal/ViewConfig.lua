local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")

local Layout = require("thetan.irizz.views.modals.ChartInfoModal.Layout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textChartInfo
local Font = Theme:getFonts("chartInfoModal")

local ViewConfig = class()

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

function ViewConfig:info(view)
	if not view.item then
		return
	end

	Layout:move("info")

	just.next(0, 15)
	love.graphics.setFont(Font.info)
	love.graphics.setColor(Color.text)
	for _, field in ipairs(orderedInfo) do
		just.indent(15)
		just.text(("%s: %s"):format(field[2], tostring(view.item[field[1]])))
	end

	Layout:move("info")
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	just.indent(5)
	gyatt.frame(Text.chartInfo, 0, 0, w, h, "left", "center")

	self:info(view)
end

return ViewConfig
