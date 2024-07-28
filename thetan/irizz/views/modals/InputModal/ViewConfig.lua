local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")

local Format = require("sphere.views.Format")

local InputListView = require("thetan.irizz.views.modals.InputModal.InputListView")

local Theme = require("thetan.irizz.views.Theme")
local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local Layout = require("thetan.irizz.views.modals.InputModal.Layout")

---@class irizz.InputModalViewConfig : IViewConfig
---@operator call: irizz.InputModalViewConfig
local ViewConfig = IViewConfig + {}

local inputMode = ""

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ViewConfig:new(game, assets)
	text, font = assets.localization:get("inputModal")
	assert(text)
	assert(font)

	self.inputListView = InputListView(game, assets)
end

function ViewConfig:inputs(view)
	local w, h = Layout:move("inputs")
	Theme:panel(w, h)
	Theme:border(w, h)

	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.inputs)

	self.inputListView:draw(w, h, true)
end

function ViewConfig:inputMode(view)
	local w, h = Layout:move("inputMode")

	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.inputMode)

	inputMode = Format.inputMode(inputMode)
	inputMode = inputMode == "2K" and "TAIKO" or inputMode

	gyatt.frame(inputMode, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("modalName")
	love.graphics.setColor(colors.ui.text)
	love.graphics.setFont(font.title)
	gyatt.frame(text.inputs, 0, 0, w, h, "center", "center")

	inputMode = view.inputMode

	self:inputs(view)
	self:inputMode(view)
end

return ViewConfig
