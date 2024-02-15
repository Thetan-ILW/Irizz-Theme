local gfx_util = require("gfx_util")
local imgui = require("thetan.iris.imgui")

local Layout = require("thetan.iris.views.modals.MountsModal.Layout")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textMounts
local Font = Theme:getFonts("mountsModal")

local ViewConfig = {}

function ViewConfig:mounts(view)
	local w, h = Layout:move("window")

	Theme:panel(w, h)
	self.mountsListView:draw(w, h, true)
	Theme:border(w, h)
end

function ViewConfig:buttons(view)
	local w, h = Layout:move("buttons")

	Theme:panel(w, h)
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.tabs)

	h = h / 2

	local selectedItem = self.mountsListView.selectedItem
	local items = self.mountsListView.items

	if imgui.TextOnlyButton("openMount", "Open", w, h, "center", false) then
		if not selectedItem then
			return
		end

		love.system.openURL(selectedItem[1])
	end

	if imgui.TextOnlyButton("removeMount", "Remove", w, h, "center", false) then
		if not selectedItem then
			return
		end

		for i = 1, #items do
			if items[i] == selectedItem then
				table.remove(items, i)
				selectedItem = nil
				break
			end
		end
	end

	w, h = Layout:move("buttons")
	Theme:border(w, h)
end

function ViewConfig:path(view)
	local w, h = Layout:move("path")

	local selectedItem = self.mountsListView.selectedItem

	if not selectedItem then
		return
	end

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.path)
	gfx_util.printFrame(selectedItem[1], 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.mounts, 0, 0, w, h, "center", "center")

	self:mounts(view)
	self:buttons(view)
	self:path(view)
end

return ViewConfig

