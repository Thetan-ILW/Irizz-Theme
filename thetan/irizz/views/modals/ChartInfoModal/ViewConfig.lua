local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")

local Layout = require("thetan.irizz.views.modals.ChartInfoModal.Layout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textChartInfo
local Font = Theme:getFonts("chartInfoModal")

local ViewConfig = class()

function ViewConfig:info(view)
	Layout:move("info")

	just.next(0, 15)
	love.graphics.setFont(Font.info)
	love.graphics.setColor(Color.text)

	for _, text in ipairs(view.infoCache) do
		just.indent(15)
		just.text(text)
		just.next(0, 10)
	end

	local w, _ = Layout:move("info")
	gyatt.text(view.ssrCache, w, "right")
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
