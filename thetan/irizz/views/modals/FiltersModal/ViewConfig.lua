local class = require("class")

local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")
local just = require("just")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textFilters
local Font = Theme:getFonts("filtersModal")
local cfg = Theme.imgui

local Layout = require("thetan.irizz.views.modals.FiltersModal.Layout")
local Container = require("thetan.gyatt.Container")

local ViewConfig = class()

ViewConfig.osuDirect = false

function ViewConfig:new()
	self.container = Container("filtersContainer")
end

local function filter_to_string(f)
	return f.name
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
	local uiW = w / 2.5
	local uiH = cfg.size

	self.container:startDraw(w, h)
	imgui.setSize(w, h, uiW, uiH)

	love.graphics.setFont(Font.headerText)
	love.graphics.setColor(Color.text)

	imgui.separator()
	just.text(Text.scores)
	just.next(0, 15)

	local scoreFilters = view.game.configModel.configs.filters.score
	local select = view.game.configModel.configs.select

	local f =
		imgui.spoilerList("ScoreFilterDropdown", scoreFilters, select.scoreFilterName, filter_to_string, Text.inputMode)
	if f then
		select.scoreFilterName = scoreFilters[f].name
	end

	local sources = view.game.selectModel.scoreLibrary.scoreSources
	local i = imgui.spoilerList("ScoreSourceDropdown", sources, select.scoreSourceName, nil, Text.scoresSource)
	if i then
		select.scoreSourceName = sources[i]
	end

	imgui.separator()
	just.text(Text.charts)
	just.next(0, 15)

	ss.chartdiffs_list = imgui.checkbox("ss.chartdiffs_list", ss.chartdiffs_list, Text.moddedCharts)

	local sortFunction = view.game.configModel.configs.select.sortFunction
	local sortModel = view.game.selectModel.sortModel

	local a = imgui.spoilerList("SortDropdown", sortModel.names, sortFunction, nil, Text.sort)
	local name = sortModel.names[a]
	if name then
		view.game.selectModel:setSortFunction(name)
	end

	imgui.separator()
	for _, group in ipairs(filters) do
		if group.name == "chartmeta" or group.name == "chartdiff" then
			goto continue
		end

		love.graphics.setFont(Font.headerText)
		love.graphics.setColor(Color.text)

		just.row(true)
		local name = Theme.formatFilter(group.name)
		just.text(name)
		just.next(210 - Font.headerText:getWidth(name))

		love.graphics.setFont(Font.checkboxes)
		for _, filter in ipairs(group) do
			local is_active = filterModel:isActive(group.name, filter.name)
			local new_is_active = imgui.textcheckbox(filter, is_active, filter.name)
			if new_is_active ~= is_active then
				filterModel:setFilter(group.name, filter.name, new_is_active)
				filterModel:apply()
				view.game.selectModel:noDebouncePullNoteChartSet()
			end
		end
		just.row()

		::continue::
	end

	self.container.scrollLimit = just.height - heightStart - h
	self.container:stopDraw()
	w, h = Layout:move("filters")
	Theme:border(w, h)
end

function ViewConfig:osuDirectFilters(view)
	local w, h = Layout:move("filters")

	Theme:panel(w, h)

	local heightStart = just.height
	local uiW = w / 2.5
	local uiH = cfg.size

	self.container:startDraw(w, h)
	imgui.setSize(w, h, uiW, uiH)

	love.graphics.setFont(Font.headerText)
	love.graphics.setColor(Color.text)
	imgui.separator()
	just.text(Text.osuDirect)
	just.next(0, 15)

	local osudirectModel = view.game.osudirectModel
	local statusIndex = imgui.spoilerList(
		"RankedStatusDropdown",
		osudirectModel.rankedStatuses,
		osudirectModel.rankedStatus,
		nil,
		Text.rankedStatus
	)

	if statusIndex then
		osudirectModel:setRankedStatus(osudirectModel.rankedStatuses[statusIndex])
	end

	self.container.scrollLimit = just.height - heightStart - h
	self.container:stopDraw()
	w, h = Layout:move("filters")
	Theme:border(w, h)
end

function ViewConfig:chartsLine(view)
	local w, h = Layout:move("filterLine")

	local count = #view.game.selectModel.noteChartSetLibrary.items
	local tree = view.game.selectModel.collectionLibrary.tree
	local path = tree.items[tree.selected].name

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.filtersLine)

	gfx_util.printFrame(Text.chartCount:format(count, path), 0, 0, w, h, "center", "center")
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

	if self.osuDirect then
		self:osuDirectFilters(view)
	else
		self:filters(view)
	end
	self:chartsLine(view)
end

return ViewConfig
