local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")
local just = require("just")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")

local Layout = require("thetan.irizz.views.modals.FiltersModal.Layout")
local Container = require("thetan.gyatt.Container")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ViewConfig = IViewConfig + {}

ViewConfig.osuDirect = false

---@param assets irizz.IrizzAssets
function ViewConfig:new(assets)
	self.container = Container("filtersContainer")

	text, font = assets.localization:get("filtersModal")
end

local function filter_to_string(f)
	return f.name
end

local filterAliasses = {
	["(not) played"] = "played",
	["actual input mode"] = "actualInputMode",
	["original input mode"] = "inputMode",
	format = "format",
	scratch = "scratch",
}

---@param v string
---@return string
local function formatFilter(v)
	return text[filterAliasses[v]] or v
end

function ViewConfig:filters(view)
	local filterModel = view.game.selectModel.filterModel
	local filters = view.game.configModel.configs.filters.notechart
	local configs = view.game.configModel.configs
	local settings = configs.settings
	local ss = settings.select

	local w, h = Layout:move("filters")

	ui:panel(w, h)

	local heightStart = just.height
	local uiW = w / 2.5
	local uiH = 50

	self.container:startDraw(w, h)
	imgui.setSize(w, h, uiW, uiH)

	love.graphics.setFont(font.headerText)
	love.graphics.setColor(colors.ui.text)

	imgui.separator()
	gyatt.text(text.scores)
	just.next(0, 15)

	local scoreFilters = view.game.configModel.configs.filters.score
	local select = view.game.configModel.configs.select

	local f =
		imgui.spoilerList("ScoreFilterDropdown", scoreFilters, select.scoreFilterName, filter_to_string, text.inputMode)
	if f then
		select.scoreFilterName = scoreFilters[f].name
	end

	local sources = view.game.selectModel.scoreLibrary.scoreSources
	local i = imgui.spoilerList("ScoreSourceDropdown", sources, select.scoreSourceName, nil, text.scoresSource)
	if i then
		select.scoreSourceName = sources[i]
	end

	imgui.separator()
	gyatt.text(text.charts)
	just.next(0, 15)

	ss.chartdiffs_list = imgui.checkbox("ss.chartdiffs_list", ss.chartdiffs_list, text.moddedCharts)

	local sortFunction = view.game.configModel.configs.select.sortFunction
	local sortModel = view.game.selectModel.sortModel

	local a = imgui.spoilerList("SortDropdown", sortModel.names, sortFunction, nil, text.sort)
	local name = sortModel.names[a]
	if name then
		view.game.selectModel:setSortFunction(name)
	end

	imgui.separator()
	for _, group in ipairs(filters) do
		if group.name == "chartmeta" or group.name == "chartdiff" then
			goto continue
		end

		love.graphics.setFont(font.headerText)
		love.graphics.setColor(colors.ui.text)

		just.row(true)
		local name = formatFilter(group.name)
		gyatt.text(name, 170)

		love.graphics.setFont(font.checkboxes)
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
	ui:border(w, h)
end

function ViewConfig:osuDirectFilters(view)
	local w, h = Layout:move("filters")

	ui:panel(w, h)

	local heightStart = just.height
	local uiW = w / 2.5
	local uiH = cfg.size

	self.container:startDraw(w, h)
	imgui.setSize(w, h, uiW, uiH)

	love.graphics.setFont(font.headerText)
	love.graphics.setColor(colors.ui.text)
	imgui.separator()
	gyatt.text(text.osuDirect)
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
	ui:border(w, h)
end

function ViewConfig:chartsLine(view)
	local w, h = Layout:move("filterLine")

	local count = #view.game.selectModel.noteChartSetLibrary.items
	local tree = view.game.selectModel.collectionLibrary.tree
	local path = tree.items[tree.selected].name

	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.filtersLine)

	gyatt.frame(text.chartCount:format(count, path), 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()
	love.graphics.setLineWidth(4)

	local w, h = Layout:move("modalName")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.title)
	gyatt.frame(text.filters, 0, 0, w, h, "center", "center")

	if self.osuDirect then
		self:osuDirectFilters(view)
	else
		self:filters(view)
	end
	self:chartsLine(view)
end

return ViewConfig
