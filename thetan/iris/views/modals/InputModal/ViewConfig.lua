local gfx_util = require("gfx_util")
local imgui = require("thetan.iris.imgui")

local Format = require("sphere.views.Format")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textInputs
local Font = Theme:getFonts("inputsModal")

local Layout = require("thetan.iris.views.modals.InputModal.Layout")

local ViewConfig = {}

local currentTab = ""
local tabs = {}

local inputMode = ""

function ViewConfig:createTabs(devices)
	tabs = devices
	currentTab = tabs[1]
end

function ViewConfig:tabs(view)
	local w, h = Layout:move("tabs")
	love.graphics.setColor(Color.panel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local devices = view.game.inputModel.devices
	local tabsCount = #devices
	h = h / tabsCount

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.tabs)

	for _, device in ipairs(devices) do
		if imgui.TextOnlyButton(device, device, w, h, "center", device == currentTab) then
			currentTab = device
		end
	end

	w, h = Layout:move("tabs")
	love.graphics.setColor(Color.border)
	love.graphics.rectangle("line", 0, 0, w, h)
end

function ViewConfig:inputs(view)
	local w, h = Layout:move("inputs")
	love.graphics.setColor(Color.panel)
	love.graphics.rectangle("fill", 0, 0, w, h)

	love.graphics.setColor(Color.border)
	love.graphics.rectangle("line", 0, 0, w, h)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.inputs)

	self.inputListView.inputMode = inputMode
	self.inputListView.device = currentTab
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

	local w, h = Layout:move("base")
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, w, h)

	w, h = Layout:move("modalName")
	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.title)
	gfx_util.printFrame(Text.inputs, 0, 0, w, h, "center", "center")

	inputMode = tostring(view.game.selectController.state.inputMode)

	self:tabs(view)
	self:inputs(view)
	self:inputMode(view)
end

return ViewConfig

