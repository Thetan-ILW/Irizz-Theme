local just = require("just")
local imgui = require("thetan.iris.imgui")

local Format = require("sphere.views.Format")
local ListView = require("thetan.iris.views.ListView")

local Theme = require("thetan.iris.views.Theme")
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

	for i = 1, #inputs do
		local virtualKey = inputs[i]
		local t = { virtualKey, {} }

		for j = 1, 2 do
			local key = self.game.inputModel:getKey(self.inputMode, virtualKey, self.device, j)
			table.insert(t[2], key)
		end

		table.insert(keys, t)
	end

	self.items = keys
end

function InputListView:drawItem(i, w, h)
	local item = self.items[i]
	self:drawItemBody(w, h, i, false)

	love.graphics.setColor(Color.text)
	imgui.setSize(w, h, w / 4, h * 0.7)

	just.row(true)
	love.graphics.translate(15, 10)
	just.text(Format.inputMode(item[1]), 70)

	for index, key in ipairs(item[2]) do
		local newBind = imgui.hotkey(item[1] .. index, key, "")

		if newBind ~= item[2] then
			self.game.inputModel:setKey(self.inputMode, item[1], self.device, newBind, index)
		end
	end

	just.row()
end

return InputListView

