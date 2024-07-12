local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")
local just = require("just")
local gyatt = require("thetan.gyatt")

local TextBox = require("thetan.irizz.imgui.TextBox")

local Layout = require("thetan.irizz.views.modals.MountsModal.Layout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textMounts
local Font = Theme:getFonts("mountsModal")

local ViewConfig = {}

local tab = Text.locations

function ViewConfig:mounts(view)
	local locationsRepo = view.game.cacheModel.locationsRepo
	local locationManager = view.game.cacheModel.locationManager
	local selected_loc = locationManager.selected_loc

	local w, h = Layout:move("listPanel")

	Theme:panel(w, h)
	w, h = Layout:move("list")
	self.mountsListView:draw(w, h, true)

	w, h = Layout:move("listLine")
	love.graphics.setColor(Color.separator)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("listButton")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.buttons)

	w = w / 2

	local overCreate = just.is_over(w, h)

	if overCreate then
		love.graphics.setColor(Color.uiHover)
		love.graphics.rectangle("fill", 0, 0, w, h)
		love.graphics.setColor(Color.text)
	end

	gfx_util.printFrame(Text.create, 0, -3, w, h, "center", "center")

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
		love.graphics.setColor(Color.uiHover)
		love.graphics.rectangle("fill", 0, 0, w, h)
		love.graphics.setColor(Color.text)
	end

	gfx_util.printFrame(Text.delete, 0, -3, w, h, "center", "center")

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
	Theme:border(w, h)
end

function ViewConfig:locations(view)
	local locationsRepo = view.game.cacheModel.locationsRepo
	local locationManager = view.game.cacheModel.locationManager
	local selected_loc = locationManager.selected_loc

	local w, h = Layout:move("window")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.windowText)

	local uiW = w / 2.5
	local uiH = Theme.imgui.size
	imgui.setSize(w, h, uiW, uiH)

	Theme:panel(w, h)
	Theme:border(w, h)

	if not selected_loc then
		return
	end

	love.graphics.translate(15, 15)
	w = w - 30
	local path = selected_loc.path

	if not selected_loc.is_internal then
		love.graphics.setFont(Font.fields)

		local changed, text = TextBox("loc name", { selected_loc.name, "Name" }, nil, w, h, false)
		if changed then
			locationsRepo:updateLocation({
				id = selected_loc.id,
				name = text,
			})
			locationManager:selectLocations()
			locationManager:selectLocation(selected_loc.id)
		end

		love.graphics.setFont(Font.windowText)
		love.graphics.setColor(Color.text)
	end

	if imgui.button("cache_button", Text.update) then
		view.game.selectController:updateCacheLocation(selected_loc.id)
	end

	just.sameline()
	just.indent(15)

	if imgui.button("reset dir", Text.deleteCache) then
		locationManager:deleteCharts(selected_loc.id)
		view.game.selectModel:noDebouncePullNoteChartSet()
	end

	if selected_loc.is_internal then
		just.indent(8)
		just.text("Internal")
	end

	just.indent(8)
	just.text("Real path: ")
	just.indent(8)
	if path then
		imgui.url("open dir", path, path, false, w)
	else
		just.text(Text.notSpecified)
	end
end

function ViewConfig:database(view)
	local w, h = Layout:move("window")
	local cacheModel = view.game.cacheModel
	local cacheStatus = view.game.cacheModel.cacheStatus

	Theme:panel(w, h)

	love.graphics.translate(15, 15)
	imgui.separator()

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.textHeader)
	gyatt.text(Text.chartdiffs, w, "left")

	love.graphics.setFont(Font.windowText)
	gyatt.text(Text.computed:format(cacheStatus.chartdiffs), w, "left")
	love.graphics.translate(0, 15)

	if imgui.button("computeScores", Text.compute) then
		cacheModel:computeChartdiffs()
		cacheStatus:update()
	end

	just.sameline()
	just.indent(15)

	if imgui.button("delete chartdiffs", Text.delete) then
		view.game.cacheModel.chartdiffsRepo:deleteChartdiffs()
		cacheStatus:update()
	end

	if imgui.button("compute cds", Text.computeMissing) then
		cacheModel:computeChartdiffs()
	end

	if imgui.button("compute incomplete cds", Text.computeIncomplete) then
		cacheModel:computeIncompleteChartdiffs()
	end

	if imgui.button("compute incomplete cds pp", Text.computeIncompleteUsePreview) then
		cacheModel:computeIncompleteChartdiffs(true)
	end

	imgui.separator()
	love.graphics.setFont(Font.textHeader)
	gyatt.text(Text.chartmetas, w, "left")

	love.graphics.setFont(Font.windowText)
	gyatt.text(Text.computed:format(cacheStatus.chartmetas), w, "left")
	love.graphics.translate(0, 15)

	if imgui.button("delete chartmetas", Text.delete) then
		view.game.cacheModel.chartmetasRepo:deleteChartmetas()
		cacheStatus:update()
	end

	Layout:move("window")
	Theme:border(w, h)
end

function ViewConfig:tabButtons()
	local w, h = Layout:move("buttons")
	love.graphics.setFont(Font.buttons)
	Theme:panel(w, h)

	if imgui.TextOnlyButton("locationsTab", Text.locations, w, h / 2, "center", tab == Text.locations) then
		tab = Text.locations
		Theme:playSound("tabButtonClick")
	end

	if imgui.TextOnlyButton("databaseTab", Text.database, w, h / 2, "center", tab == Text.database) then
		tab = Text.database
		Theme:playSound("tabButtonClick")
	end

	Layout:move("buttons")
	Theme:border(w, h)
end

function ViewConfig:draw(view)
	Layout:draw()

	self.mountsListView:reloadItems()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.mounts, 0, 0, w, h, "center", "center")

	self:mounts(view)

	if tab == Text.locations then
		self:locations(view)
	else
		local cacheStatus = view.game.cacheModel.cacheStatus
		cacheStatus:update()
		self:database(view)
	end

	self:tabButtons()
end

return ViewConfig
