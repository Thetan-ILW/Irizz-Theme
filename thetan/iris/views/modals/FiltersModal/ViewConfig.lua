local class = require("class")

local gfx_util = require("gfx_util")
local imgui = require("thetan.iris.imgui")
local just = require("just")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textFilters
local Font = Theme:getFonts("filtersModal")
local cfg = Theme.imgui

local Layout = require("thetan.iris.views.modals.FiltersModal.Layout")
local Container = require("thetan.gyatt.Container")
local TextBox = require("thetan.iris.imgui.TextBox")

local ViewConfig = class()

local activeFilters = ""
local lamp = ""

function ViewConfig:new()
	self.container = Container("filtersContainer")
end

function ViewConfig:filters(view)
	local filterModel = view.game.selectModel.filterModel
	local filters = view.game.configModel.configs.filters.notechart
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local ss = settings.select

	local w, h = Layout:move("filters")

	Theme:panel(w, h)

	local heightStart = just.height
	self.container:startDraw(w, h)
	imgui.setSize(w, h, w / 2.5, cfg.size)

	love.graphics.setFont(Font.headerText)
	love.graphics.setColor(Color.text)

	imgui.separator()
	just.text(Text.filters)
	just.next(0, 15)

	ss.chartdiffs_list = imgui.checkbox("ss.chartdiffs_list", ss.chartdiffs_list, Text.moddedCharts)

	local changed, text = TextBox("filtersLamp", { lamp, "lamp"}, nil, w/2, h, false)

	if changed == "text" then
		lamp = text
	end

	for _, group in ipairs(filters) do
		imgui.separator()
		love.graphics.setColor(Color.text)
		just.text(group.name)
		just.next(0, 15)
		just.row(true)
		love.graphics.setFont(Font.checkboxes)
		for _, filter in ipairs(group) do
			local is_active = filterModel:isActive(group.name, filter.name)
			local new_is_active = imgui.textcheckbox(filter, is_active, filter.name)
			if new_is_active ~= is_active then
				filterModel:setFilter(group.name, filter.name, new_is_active)
			end
		end
		just.row()
	end

	self.container.scrollLimit = just.height - heightStart - h
	self.container:stopDraw()
	w, h = Layout:move("filters")
	Theme:border(w, h)
end

function ViewConfig:filterLine(view)
	local w, h = Layout:move("filterLine")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.filtersLine)

	gfx_util.printFrame(activeFilters, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.filters, 0, 0, w, h, "center", "center")

	self:filters(view)
	self:filterLine(view)
end

return ViewConfig
