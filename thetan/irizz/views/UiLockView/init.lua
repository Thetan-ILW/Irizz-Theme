local IViewConfig = require("thetan.skibidi.views.IViewConfig")
local Layout = require("thetan.irizz.views.UiLockView.Layout")

local gyatt = require("thetan.gyatt")
local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local gfx = love.graphics

---@class irizz.UiLockViewConfig : IViewConfig
---@operator call: irizz.UiLockViewConfig
local ViewConfig = IViewConfig + {}

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ViewConfig:new(game, assets)
	self.game = game
	text, font = assets.localization:get("uiLock")
	assert(text and font)
end

function ViewConfig:draw()
	if not self.game.cacheModel.isProcessing then
		return
	end

	Layout:draw()

	local cache_model = self.game.cacheModel
	local location_manager = self.game.cacheModel.locationManager

	---@type number
	local selected_loc = location_manager.selected_loc
	---@type string
	local path = selected_loc.path

	local count = cache_model.shared.chartfiles_count
	local current = cache_model.shared.chartfiles_current

	local w, h = Layout:move("background")
	gfx.setColor(0, 0, 0, 0.75)
	gfx.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("title")
	gfx.setColor(colors.ui.text)
	gfx.setFont(font.title)
	gyatt.frame(text.processingCharts, 0, 0, w, h, "center", "center")

	w, h = Layout:move("background")
	gfx.setFont(font.status)

	local label = ("%s: %s\n%s: %s/%s\n%s: %0.02f%%"):format(
		text.path,
		path,
		text.chartsFound,
		current,
		count,
		text.chartsCached,
		current / count * 100
	)

	gyatt.frame(label, 0, 0, w, h, "center", "center")
end

return ViewConfig
