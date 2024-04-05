local class = require("class")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local font = {}

local Format = require("sphere.views.Format")
local Layout = require("thetan.irizz.views.MultiplayerView.Layout")

local ViewConfig = class()

function ViewConfig:new()
	font = Theme:getFonts("multiplayerView")
end

function ViewConfig:footer(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	love.graphics.setFont(font.titleAndDifficulty)

	local leftText = string.format("%s - %s", chartview.artist, chartview.title)
	local rightText

	if not chartview.creator or chartview.creator == "" then
		rightText = string.format("[%s] %s", Format.inputMode(chartview.chartdiff_inputmode), chartview.name)
	else
		rightText = string.format(
			"[%s] [%s] %s",
			Format.inputMode(chartview.chartdiff_inputmode),
			chartview.creator or "",
			chartview.name
		)
	end

	local w, h = Layout:move("footerTitle")
	Theme:textWithShadow(leftText, w, h, "left", "top")
	w, h = Layout:move("footerChartName")
	Theme:textWithShadow(rightText, w, h, "right", "top")
end

function ViewConfig:draw(view)
	Layout:draw()
	self:footer(view)
end

return ViewConfig
