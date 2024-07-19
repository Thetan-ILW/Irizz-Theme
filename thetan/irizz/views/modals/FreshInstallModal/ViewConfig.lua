local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")

local Layout = require("thetan.irizz.views.modals.FreshInstallModal.Layout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textFreshInstallModal
local Font = Theme:getFonts("freshInstallModal")

local ViewConfig = class()

local gfx = love.graphics

local button_width = 500
local button_height = 60

local function button(text, on_click)
	local changed, active, hovered = gyatt.button(text .. "import", gyatt.isOver(button_width, button_height))

	gfx.setColor(Color.uiFrames)

	if hovered then
		gfx.setColor(Color.accent)
	end

	local button_gradient = Theme.images.button_gradient
	gfx.draw(button_gradient, 0, 0, 0, 1, 5)
	gyatt.frame(text, 0, 0, button_width, button_height, "center", "center")
	gfx.draw(button_gradient, 0, button_height, 0, 1, 5)

	gfx.setColor(Color.uiFrames)

	if changed then
		on_click()
	end
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("modalName")
	gfx.setColor(Color.text)
	gfx.setFont(Font.title)
	just.indent(5)
	gyatt.frame(Text.importCharts, 0, 0, w, h, "center", "center")

	gfx.setFont(Font.list)
	w, h = Layout:move("list")

	local tw = 0

	for _, songs in ipairs(view.newSongs) do
		tw = math.max(tw, Font.list:getWidth(songs[2]))
	end

	gfx.translate((w / 2) - (tw / 2) - 80, 0)
	Theme:panel(tw + 160, h)

	w, h = Layout:move("list")
	gfx.setColor(Color.text)

	gfx.translate(0, 10)

	for i, v in ipairs(view.newSongs) do
		gyatt.text(("%s"):format(v[2]), w, "center")
	end

	w, h = Layout:move("buttons")

	local x = (w / 2) - (button_width / 2)
	local y = (h / 2) - (button_height / 2)

	gfx.translate(x - (button_width / 2), y)
	button(Text.yes, function()
		view.mountAndCache = true
	end)

	gfx.translate(button_width, 0)
	button(Text.no, function()
		view:quit()
	end)

	w, h = Layout:move("base")
	imgui.setSize(w, h, w / 2.5, 55)

	local configs = view.game.configModel.configs
	local irizz = configs.irizz

	gfx.translate(15, h - 60)
	irizz.showFreshInstallModal = imgui.checkbox("showFreshInstallModal ", irizz.showFreshInstallModal, Text.show)
end
