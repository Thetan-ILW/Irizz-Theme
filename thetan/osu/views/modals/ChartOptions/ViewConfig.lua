local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.osu.views.OsuLayout")

local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
---@type table<string, love.Font>
local font

local Button = require("thetan.osu.ui.Button")

---@class osu.ChartOptionsModalViewConfig: IViewConfig
---@operator call: osu.ChartOptionsModalViewConfig
local ViewConfig = IViewConfig + {}

local gfx = love.graphics

local manage_locations ---@type osu.ui.Button
local chart_info ---@type osu.ui.Button
local filters ---@type osu.ui.Button
local edit ---@type osu.ui.Button
local file_manager ---@type osu.ui.Button
local cancel ---@type osu.ui.Button

---@param assets osu.OsuSelectAssets
function ViewConfig:new(assets)
	local scale = 0.9
	local width = 2.76
	local green = { 0.52, 0.72, 0.12, 1 }
	local purple = { 0.72, 0.4, 0.76, 1 }
	local red = { 0.91, 0.19, 0, 1 }
	local gray = { 0.42, 0.42, 0.42, 1 }

	font = Theme:getFonts("osuChartOptionsModal")
	local b_font = font.buttons

	manage_locations = Button(assets, {
		text = "1. Manage locations",
		scale = scale,
		width = width,
		color = green,
		font = b_font,
	})

	chart_info = Button(assets, {
		text = "2. Chart info",
		scale = scale,
		width = width,
		color = purple,
		font = b_font,
	})

	filters = Button(assets, {
		text = "3. Filters",
		scale = scale,
		width = width,
		color = green,
		font = b_font,
	})

	edit = Button(assets, {
		text = "4. Edit",
		scale = scale,
		width = width,
		color = red,
		font = b_font,
	})

	file_manager = Button(assets, {
		text = "5. Open in file manager",
		scale = scale,
		width = width,
		color = purple,
		font = b_font,
	})

	cancel = Button(assets, {
		text = "6. Close",
		scale = scale,
		width = width,
		color = gray,
		font = b_font,
	})
end

local window_height = love.graphics.getHeight()

function ViewConfig:resolutionUpdated()
	local wh = love.graphics.getHeight()
	window_height = wh
	font = Theme:getFonts("osuChartOptionsModal", wh / 768)
end

function ViewConfig:draw(view)
	Layout:draw()
	gyatt.setTextScale(768 / window_height)
	local w, h = Layout:move("base")

	gfx.push()
	gfx.translate(9, 9)
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.setFont(font.title)

	---@type table
	local chartview = view.game.selectModel.chartview
	local chart_name = string.format("%s - %s [%s]", chartview.artist, chartview.title, chartview.name)
	gyatt.text(("%s\nWhat do you want to do with this chart?"):format(chart_name))

	gfx.pop()

	local bw, bh = manage_locations:getDimensions()
	local total_h = (h / 2) - ((bh / 2) * 6) - (manage_locations.spacing * 5) / 2
	gfx.translate(w / 2 - bw / 2, 10 + total_h)

	manage_locations:draw()
	chart_info:draw()
	filters:draw()

	if edit:draw() then
		view.mainView:edit()
	end

	if file_manager:draw() then
		view.game.selectController:openDirectory()
	end

	if cancel:draw() then
		view:quit()
	end
end

return ViewConfig
