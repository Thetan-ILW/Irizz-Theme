local just = require("just")
local imgui = require("thetan.iris.imgui")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textModifiers
--local Font = Theme:getFonts("modifiersModal")

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

	local devices = view.game.inputModel.devices
	local tabsCount = #devices
	h = h / tabsCount

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

    love.graphics.setColor(Color.border)
    love.graphics.rectangle("line", 0, 0, w, h)

    self.inputListView.inputMode = inputMode
    self.inputListView.device = currentTab
    self.inputListView:draw(w, h)
end

function ViewConfig:draw(view)
    Layout:draw()

    local w, h = Layout:move("base")
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, w, h)

    inputMode = tostring(view.game.selectController.state.inputMode)

    self:tabs(view)
    self:inputs(view)
end

return ViewConfig