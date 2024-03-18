local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")

local Layout = require("thetan.irizz.views.modals.MountsModal.Layout")

local Theme = require("thetan.irizz.views.Theme")
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
end

return ViewConfig

