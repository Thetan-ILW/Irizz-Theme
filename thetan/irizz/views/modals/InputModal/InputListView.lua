local just = require("just")
local imgui = require("thetan.irizz.imgui")

local Format = require("sphere.views.Format")
local ListView = require("thetan.irizz.views.ListView")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
local Text = Theme.textInputs

local InputListView = ListView + {}

InputListView.rows = 11
InputListView.centerItems = false
InputListView.noItemsText = Text.noInputs
InputListView.scrollSound = Theme.sounds.scrollSoundLargeList
InputListView.device = ""
InputListView.inputMode = ""

function InputListView:new(game)
	self.game = game
	self.font = Theme:getFonts("inputsModal")
end

function InputListView:reloadItems()
	local inputs = self.game.inputModel:getInputs(self.inputMode)

	if #inputs == 0 then
		self.items = {}
		return
	end

	local keys = {}

	local inputModel = self.game.inputModel
	local bindsCount = inputModel:getBindsCount(self.inputMode)

	for i = 1, #inputs do
		local virtualKey = inputs[i]
		local t = { inputCount = #inputs, virtualKey = virtualKey, inputs = {} }

		for j = 1, bindsCount + 1 do
			local key, device, deviceId = inputModel:getKey(self.inputMode, virtualKey, j)

			if key == nil then
				key = ""
			end

			table.insert(t.inputs, key)
		end
		table.insert(keys, t)
	end
	self.items = keys
end

function InputListView:drawItem(i, w, h)
	local item = self.items[i]
	self:drawItemBody(w, h, i, false)

	love.graphics.setColor(Color.text)
	imgui.setSize(w, h, w / 11, h * 0.7)

	just.row(true)
	love.graphics.translate(15, 10)
	just.text(Format.inputMode(item.virtualKey), 70)

	local inputIdPattern = "input hotkey %s %s"

	for index, value in ipairs(item.inputs) do
		local virtualKey = item.virtualKey
		local hotkeyId = inputIdPattern:format(i, index)
		local newBind, device, deviceId = imgui.hotkey(hotkeyId, value, "")

		if newBind ~= value then
			self.game.inputModel:setKey(self.inputMode, virtualKey, index, device, deviceId, newBind)
			
			if i + 1 <= item.inputCount and newBind then
				just.focus(inputIdPattern:format(i + 1, index))
			end
		end
	end

	just.row()
end

return InputListView

