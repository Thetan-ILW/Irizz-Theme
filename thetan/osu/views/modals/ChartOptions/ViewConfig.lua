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

local open_time = 0

---@param assets osu.OsuSelectAssets
function ViewConfig:new(assets)
	local scale = 0.9
	local width = 2.76
	local green = { 0.52, 0.72, 0.12, 1 }
	local purple = { 0.72, 0.4, 0.76, 1 }
	local red = { 0.91, 0.19, 0, 1 }
	local gray = { 0.42, 0.42, 0.42, 1 }

	font = assets.localization.fontGroups.chartOptionsModal
	local text = assets.localization.textGroups.chartOptionsModal

	local b_font = font.buttons

	manage_locations = Button(assets, {
		text = text.manageLocations,
		scale = scale,
		width = width,
		color = green,
		font = b_font,
	})

	chart_info = Button(assets, {
		text = text.chartInfo,
		scale = scale,
		width = width,
		color = purple,
		font = b_font,
	})

	filters = Button(assets, {
		text = text.filters,
		scale = scale,
		width = width,
		color = green,
		font = b_font,
	})

	edit = Button(assets, {
		text = text.edit,
		scale = scale,
		width = width,
		color = red,
		font = b_font,
	})

	file_manager = Button(assets, {
		text = text.fileManager,
		scale = scale,
		width = width,
		color = purple,
		font = b_font,
	})

	cancel = Button(assets, {
		text = text.cancel,
		scale = scale,
		width = width,
		color = gray,
		font = b_font,
	})

	open_time = love.timer.getTime()
end

local window_height = gfx.getHeight()

function ViewConfig:resolutionUpdated()
	window_height = gfx.getHeight()
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

	local a = gyatt.easeOutCubic(open_time, 1) * 50

	gfx.translate(50 - a, 0)
	if manage_locations:draw() then
		view.mainView:switchModal("thetan.irizz.views.modals.MountsModal")
	end
	gfx.translate(a - 50, 0)

	gfx.translate(-50 + a, 0)
	if chart_info:draw() then
		view.mainView:switchModal("thetan.irizz.views.modals.ChartInfoModal")
	end

	gfx.translate(-a + 50, 0)

	gfx.translate(50 - a, 0)
	filters:draw()
	gfx.translate(a - 50, 0)

	gfx.translate(-50 + a, 0)
	if edit:draw() then
		view.mainView:edit()
	end
	gfx.translate(-a + 50, 0)

	gfx.translate(50 - a, 0)
	if file_manager:draw() then
		view.game.selectController:openDirectory()
	end
	gfx.translate(a - 50, 0)

	gfx.translate(-50 + a, 0)
	if cancel:draw() then
		view:quit()
	end
	gfx.translate(-a + 50, 0)

	gyatt.setTextScale(1)
end

return ViewConfig
