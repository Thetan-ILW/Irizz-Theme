local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local just = require("just")
local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")

local Layout = require("thetan.irizz.views.modals.FreshInstallModal.Layout")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")

---@type irizz.IrizzAssets
local assets
---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ViewConfig = IViewConfig + {}

local gfx = love.graphics

local button_width = 500
local button_height = 60

---@param _assets irizz.IrizzAssets
function ViewConfig:new(_assets)
	assets = _assets
	text, font = _assets.localization:get("freshInstallModal")
	assert(text and font)
end

local function button(label, on_click)
	local changed, active, hovered = gyatt.button(label .. "import", gyatt.isOver(button_width, button_height))

	gfx.setColor(colors.ui.uiFrames)

	if hovered then
		gfx.setColor(colors.ui.accent)
	end

	local button_gradient = assets.images.buttonGradient
	gfx.draw(button_gradient, 0, 0, 0, 1, 5)
	gyatt.frame(label, 0, 0, button_width, button_height, "center", "center")
	gfx.draw(button_gradient, 0, button_height, 0, 1, 5)

	gfx.setColor(colors.ui.uiFrames)

	if changed then
		on_click()
	end
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("modalName")
	gfx.setColor(colors.ui.text)
	gfx.setFont(font.title)
	just.indent(5)
	gyatt.frame(text.importCharts, 0, 0, w, h, "center", "center")

	gfx.setFont(font.list)
	w, h = Layout:move("list")

	local tw = 0

	for _, songs in ipairs(view.newSongs) do
		tw = math.max(tw, font.list:getWidth(songs[2]))
	end

	gfx.translate((w / 2) - (tw / 2) - 80, 0)
	ui:panel(tw + 160, h)

	w, h = Layout:move("list")
	gfx.setColor(colors.ui.text)

	gfx.translate(0, 10)

	for i, v in ipairs(view.newSongs) do
		gyatt.text(("%s"):format(v[2]), w, "center")
	end

	w, h = Layout:move("buttons")

	local x = (w / 2) - (button_width / 2)
	local y = (h / 2) - (button_height / 2)

	gfx.translate(x - (button_width / 2), y)
	button(text.yes, function()
		view.mountAndCache = true
	end)

	gfx.translate(button_width, 0)
	button(text.no, function()
		view:quit()
	end)

	w, h = Layout:move("base")
	imgui.setSize(w, h, w / 2.5, 55)

	local configs = view.game.configModel.configs
	local irizz = configs.irizz

	gfx.translate(15, h - 60)
	irizz.showFreshInstallModal = imgui.checkbox("showFreshInstallModal ", irizz.showFreshInstallModal, text.show)
end

return ViewConfig
