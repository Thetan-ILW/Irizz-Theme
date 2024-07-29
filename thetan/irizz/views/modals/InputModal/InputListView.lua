local just = require("just")
local imgui = require("thetan.irizz.imgui")
local gyatt = require("thetan.gyatt")

local Format = require("sphere.views.Format")
local ListView = require("thetan.irizz.views.ListView")

local colors = require("thetan.irizz.ui.colors")

local InputListView = ListView + {}

InputListView.rows = 11
InputListView.centerItems = false
InputListView.device = ""
InputListView.inputMode = ""

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function InputListView:new(game, assets)
	ListView:new(game)

	self.game = game
	self.text, self.font = assets.localization:get("inputModal")
	assert(self.text)
	assert(self.font)
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

local gfx = love.graphics

function InputListView:drawItem(i, w, h)
	local item = self.items[i]
	self:drawItemBody(w, h, i, false)

	gfx.setColor(colors.ui.text)
	imgui.setSize(w, h, w / 11, h * 0.7)

	gyatt.row(true)
	gfx.translate(15, 10)
	gyatt.text(Format.inputMode(item.virtualKey), 70)

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

			self:reloadItems()
		end
	end

	gyatt.row()
end

return InputListView
