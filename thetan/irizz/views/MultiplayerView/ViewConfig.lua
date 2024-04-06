local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textMultiplayerScreen
local font = {}

local Format = require("sphere.views.Format")
local Layout = require("thetan.irizz.views.MultiplayerView.Layout")

local ViewConfig = class()

local boxes = {
	"roomInfo",
	"chat",
}

local gfx = love.graphics

function ViewConfig:new()
	font = Theme:getFonts("multiplayerView")
end

function ViewConfig.panels()
	for _, name in ipairs(boxes) do
		local w, h = Layout:move(name)
		Theme:panel(w, h)
	end
end

function ViewConfig:footer(view)
	local chartview = view.game.selectModel.chartview

	if not chartview then
		return
	end

	gfx.setFont(font.titleAndDifficulty)

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

function ViewConfig:roomInfo(view)
	local w, h = Layout:move("roomInfo")

	Theme:panel(w, h)
	gfx.setFont(font.roomInfo)
	gfx.setColor(Color.text)

	h = h / 2

	gyatt.frame(Text.roomName:format(view.room.name), 0, 0, w, h, "center", "center")
	gyatt.frame(Text.playerCount:format(#view.users), 0, h, w, h, "center", "center")

	Theme:border(w, h * 2)
end

function ViewConfig:chat(view)
	local w, h = Layout:move("chat")
	Theme:panel(w, h)
	Theme:border(w, h)
end

function ViewConfig:draw(view)
	just.origin()
	self:roomInfo(view)
	self:chat(view)
	self:footer(view)
end

return ViewConfig
