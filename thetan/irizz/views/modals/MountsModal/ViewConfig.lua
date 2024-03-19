local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")
local just = require("just")

local TextBox = require("thetan.irizz.imgui.TextBox")

local Layout = require("thetan.irizz.views.modals.MountsModal.Layout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textMounts
local Font = Theme:getFonts("mountsModal")

local ViewConfig = {}

function ViewConfig:mounts(view)
	local locationsRepo = view.game.cacheModel.locationsRepo
	local locationManager = view.game.cacheModel.locationManager
	local selected_loc = locationManager.selected_loc

	local w, h = Layout:move("listPanel")

	Theme:panel(w, h)
	w, h = Layout:move("list")
	self.mountsListView:draw(w, h, true)

	w, h = Layout:move("listLine")
	love.graphics.setColor(Color.mutedBorder)
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
			name = "unnamed",
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

function ViewConfig:window(view)
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
	just.text("Status: " .. (selected_loc.status or "unknown"))
	just.indent(8)
	just.text("Real path: ")
	just.indent(8)
	if path then
		imgui.url("open dir", path, path, false, w)
	else
		just.text("not specified")
	end
end

function ViewConfig:uiLock(view)
	local cacheModel = view.game.cacheModel
	local locationManager = view.game.cacheModel.locationManager
	local selected_loc = locationManager.selected_loc
	local path = selected_loc.path

	local count = cacheModel.shared.chartfiles_count
	local current = cacheModel.shared.chartfiles_current

	local w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.processingCharts, 0, 0, w, h, "center", "center")

	w, h = Layout:move("window")
	w = math.huge
	love.graphics.setFont(Font.status)
	gfx_util.printFrame(("%s: %s"):format(Text.path, path), 0, 0, w, h, "center", "top")
	just.next(0, 50)
	gfx_util.printFrame(("%s: %s/%s"):format(Text.chartsFound, current, count), 0, 0, w, h, "center", "top")
	just.next(0, 50)
	gfx_util.printFrame(("%s: %0.2f%%"):format(Text.chartsCached, current / count * 100), 0, 0, w, h, "center", "top")
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	if view.game.cacheModel.isProcessing then
		self:uiLock(view)
		return
	end
	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.mounts, 0, 0, w, h, "center", "center")

	self:mounts(view)
	self:window(view)
end

return ViewConfig
