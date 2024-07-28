local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local just = require("just")
local gyatt = require("thetan.gyatt")

local Layout = require("thetan.irizz.views.modals.ChartInfoModal.Layout")

local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local ViewConfig = IViewConfig + {}

---@param assets irizz.IrizzAssets
function ViewConfig:new(assets)
	text, font = assets.localization:get("chartInfoModal")
	assert(text)
	assert(font)
end

function ViewConfig:info(view)
	Layout:move("info")

	just.next(0, 15)
	love.graphics.setFont(font.info)
	love.graphics.setColor(colors.ui.text)

	for _, text in ipairs(view.infoCache) do
		just.indent(15)
		gyatt.text(text)
		just.next(0, 10)
	end

	local w, _ = Layout:move("info")
	gyatt.text(view.ssrCache, w, "right")
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("modalName")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.title)
	just.indent(5)
	gyatt.frame(text.chartInfo, 0, 0, w, h, "left", "center")

	self:info(view)
end

return ViewConfig
