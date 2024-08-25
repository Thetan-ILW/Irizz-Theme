local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local imgui = require("thetan.irizz.imgui")
local just = require("just")
local gyatt = require("thetan.gyatt")

local MountsListView = require("thetan.irizz.views.modals.MountsModal.MountsListView")

local TextBox = require("thetan.irizz.imgui.TextBox")

local Layout = require("thetan.irizz.views.modals.MountsModal.Layout")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

---@class irizz.MountsModalViewConfig : IViewConfig
---@operator call: irizz.MountsModalViewConfig
local ViewConfig = IViewConfig + {}

local tab = ""

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ViewConfig:new(game, assets)
	self.mountsListView = MountsListView(game, assets)

	font = assets.localization.fontGroups.mountsModal
	text = assets.localization.textGroups.mountsModal

	tab = text.locations
end

function ViewConfig:mounts(view)
	local locationsRepo = view.game.cacheModel.locationsRepo
	local locationManager = view.game.cacheModel.locationManager
	local selected_loc = locationManager.selected_loc

	local w, h = Layout:move("listPanel")

	ui:panel(w, h)
	w, h = Layout:move("list")
	self.mountsListView:draw(w, h, true)

	w, h = Layout:move("listLine")
	love.graphics.setColor(colors.ui.separator)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("listButton")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.buttons)

	w = w / 2

	local overCreate = just.is_over(w, h)

	if overCreate then
		love.graphics.setColor(colors.ui.uiHover)
		love.graphics.rectangle("fill", 0, 0, w, h)
		love.graphics.setColor(colors.ui.text)
	end

	gyatt.frame(text.create, 0, -3, w, h, "center", "center")

	if just.button("createLocation", overCreate) then
		local location = locationsRepo:insertLocation({
			name = "Unnamed",
			is_relative = false,
			is_internal = false,
		})
		locationManager:selectLocations()
		locationManager:selectLocation(location.id)
	end

	just.indent(w)
	local overDelete = just.is_over(w, h)

	if overDelete then
		love.graphics.setColor(colors.ui.uiHover)
		love.graphics.rectangle("fill", 0, 0, w, h)
		love.graphics.setColor(colors.ui.text)
	end

	gyatt.frame(text.delete, 0, -3, w, h, "center", "center")

	if just.button("deleteLocation", overDelete) then
		if not selected_loc.is_internal then
			locationManager:deleteLocation(selected_loc.id)
			locationManager:selectLocations()
			locationManager:selectLocation(1)
			view.game.selectModel:noDebouncePullNoteChartSet()
		end
	end

	just.indent(-w)

	w, h = Layout:move("listPanel")
	ui:border(w, h)
end

function ViewConfig:locations(view)
	local locationsRepo = view.game.cacheModel.locationsRepo
	local locationManager = view.game.cacheModel.locationManager
	local selected_loc = locationManager.selected_loc

	local w, h = Layout:move("window")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.windowText)

	local uiW = w / 2.5
	local uiH = 50
	imgui.setSize(w, h, uiW, uiH)

	ui:panel(w, h)
	ui:border(w, h)

	if not selected_loc then
		return
	end

	love.graphics.translate(15, 15)
	w = w - 30
	local path = selected_loc.path

	if not selected_loc.is_internal then
		love.graphics.setFont(font.fields)

		local changed, input = TextBox("loc name", { selected_loc.name, "Name" }, nil, w, 50, false)
		if changed then
			locationsRepo:updateLocation({
				id = selected_loc.id,
				name = input,
			})
			locationManager:selectLocations()
			locationManager:selectLocation(selected_loc.id)
		end

		love.graphics.setFont(font.windowText)
		love.graphics.setColor(colors.ui.text)
	end

	if imgui.button("cache_button", text.update) then
		view.game.selectController:updateCacheLocation(selected_loc.id)
	end

	just.sameline()
	just.indent(15)

	if imgui.button("reset dir", text.deleteCache) then
		locationManager:deleteCharts(selected_loc.id)
		view.game.selectModel:noDebouncePullNoteChartSet()
	end

	if selected_loc.is_internal then
		just.indent(8)
		gyatt.text("Internal")
	end

	just.indent(8)
	gyatt.text("Real path: ")
	just.indent(8)
	if path then
		imgui.url("open dir", path, path, false, w)
	else
		gyatt.text(text.notSpecified)
	end
end

function ViewConfig:database(view)
	local w, h = Layout:move("window")
	local cacheModel = view.game.cacheModel
	local cacheStatus = view.game.cacheModel.cacheStatus

	ui:panel(w, h)

	love.graphics.translate(15, 15)
	imgui.separator()

	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.textHeader)
	gyatt.text(text.chartdiffs, w, "left")

	love.graphics.setFont(font.windowText)
	gyatt.text(text.computed:format(cacheStatus.chartdiffs), w, "left")
	love.graphics.translate(0, 15)

	if imgui.button("computeScores", text.compute) then
		cacheModel:computeChartdiffs()
		cacheStatus:update()
	end

	just.sameline()
	just.indent(15)

	if imgui.button("delete chartdiffs", text.delete) then
		view.game.cacheModel.chartdiffsRepo:deleteChartdiffs()
		cacheStatus:update()
	end

	if imgui.button("compute cds", text.computeMissing) then
		cacheModel:computeChartdiffs()
	end

	if imgui.button("compute incomplete cds", text.computeIncomplete) then
		cacheModel:computeIncompleteChartdiffs()
	end

	if imgui.button("compute incomplete cds pp", text.computeIncompleteUsePreview) then
		cacheModel:computeIncompleteChartdiffs(true)
	end

	imgui.separator()
	love.graphics.setFont(font.textHeader)
	gyatt.text(text.chartmetas, w, "left")

	love.graphics.setFont(font.windowText)
	gyatt.text(text.computed:format(cacheStatus.chartmetas), w, "left")
	love.graphics.translate(0, 15)

	if imgui.button("delete chartmetas", text.delete) then
		view.game.cacheModel.chartmetasRepo:deleteChartmetas()
		cacheStatus:update()
	end

	Layout:move("window")
	ui:border(w, h)
end

function ViewConfig:tabButtons()
	local w, h = Layout:move("buttons")
	love.graphics.setFont(font.buttons)
	ui:panel(w, h)

	if imgui.TextOnlyButton("locationsTab", text.locations, w, h / 2, "center", tab == text.locations) then
		tab = text.locations
		--Theme:playSound("tabButtonClick")
	end

	if imgui.TextOnlyButton("databaseTab", text.database, w, h / 2, "center", tab == text.database) then
		tab = text.database
		--Theme:playSound("tabButtonClick")
	end

	Layout:move("buttons")
	ui:border(w, h)
end

function ViewConfig:draw(view)
	Layout:draw()

	self.mountsListView:reloadItems()

	local w, h = Layout:move("modalName")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.title)
	gyatt.frame(text.mounts, 0, 0, w, h, "center", "center")

	self:mounts(view)

	if tab == text.locations then
		self:locations(view)
	else
		local cacheStatus = view.game.cacheModel.cacheStatus
		cacheStatus:update()
		self:database(view)
	end

	self:tabButtons()
end

return ViewConfig
