local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")

local Format = require("sphere.views.Format")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textInputs
local Font = Theme:getFonts("inputsModal")

local Layout = require("thetan.irizz.views.modals.InputModal.Layout")

local ViewConfig = {}

local inputMode = ""

function ViewConfig:inputs(view)
	local w, h = Layout:move("inputs")
	Theme:panel(w, h)
	Theme:border(w, h)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.inputs)

	self.inputListView:draw(w, h, true)
end

function ViewConfig:inputMode(view)
	local w, h = Layout:move("inputMode")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.inputMode)

	inputMode = Format.inputMode(inputMode)
	inputMode = inputMode == "2K" and "TAIKO" or inputMode

	gfx_util.printFrame(inputMode, 0, 0, w, h, "center", "center")
end

function ViewConfig:draw(view)
	Layout:draw()

	local w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.inputs, 0, 0, w, h, "center", "center")

	inputMode = view.inputMode

	self:inputs(view)
	self:inputMode(view)
end

return ViewConfig
