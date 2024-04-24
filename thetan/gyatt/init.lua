local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")
local just = require("just")
local ScrollBar = require("thetan.irizz.imgui.ScrollBar")

local gyatt = {}

gyatt.inputMode = "keyboard"
gyatt.baseline = gfx_util.printBaseline
gyatt.frame = gfx_util.printFrame
gyatt.getCanvas = gfx_util.getCanvas
gyatt.separator = imgui.separator
gyatt.setSize = imgui.setSize
gyatt.button = just.button
gyatt.isOver = just.is_over

---@param action string | table
---@return boolean
local function actionPressed(action)
	local currentTime = love.timer.getTime()

	if type(action) == "string" then
		if gyatt.isModKeyDown() then
			return false
		end

		local timeStamp = keyPressTimestamps[action]
		local pressed = timeStamp and currentTime - timeStamp <= bufferTime

		if pressed then
			keyPressTimestamps[action] = -1
			return true
		end

		return false
	end

	if action.op then
		if not gyatt.isModKeyDown() then
			if action.op == gyatt.vim.getOperation() then
				return true
			end
		end

		return false
	end

	local modKeyDown = false
	for _, k in ipairs(action.mod) do
		modKeyDown = modKeyDown or modKeysDown[k]
	end

	if not modKeyDown then
		return false
	end

	local regularKeysDown = true
	for _, key in ipairs(action) do
		if type(key) == "string" then
			local timeStamp = keyPressTimestamps[key] or -1
			regularKeysDown = regularKeysDown and currentTime - timeStamp <= bufferTime

			if not regularKeysDown then
				return false
			end
		end
	end

	if modKeyDown and regularKeysDown then
		for _, key in ipairs(action) do
			if type(key) == "string" then
				keyPressTimestamps[key] = -1
			end
		end

		return true
	end

	return false
end

---@param action string | table
---@return boolean
local function actionDown(action)
	if type(action) == "string" then
		if gyatt.isModKeyDown() then
			return false
		end

		return keysDown[action]
	end

	local modKeyDown = false
	for _, k in ipairs(action.mod) do
		modKeyDown = modKeyDown or modKeysDown[k]
	end

	if not modKeyDown then
		return false
	end

	local isDown = true
	for _, key in ipairs(action) do
		if type(key) == "string" then
			isDown = isDown and keysDown[key]
		end
	end

	if modKeyDown and isDown then
		return true
	end

	return false
end

function gyatt.actionPressed(action)
	if vim.getOperation():len() > 1 and not action.op then
		return
	end

	local isPressed = actionPressed(action)

	if isPressed then
		vim.clear()
	end

	return isPressed
end

function gyatt.actionDown(action)
	local isDown = actionDown(action)

	if isDown then
		vim.clear()
	end

	return isDown
end

function gyatt.text(text, w, ax)
	gyatt.frame(text, 0, 0, w or math.huge, math.huge, ax or "left", "top")
	just.next(0, love.graphics.getFont():getHeight())
end

---@param list irizz.ListView
---@param w number
---@param h number
function gyatt.scrollBar(list, w, h)
	local count = #list.items - 1

	love.graphics.translate(w - 16, 0)

	local pos = (list.visualItemIndex - 1) / count
	local newScroll = ScrollBar("ncs_sb", pos, 16, h, count / list.rows)
	if newScroll then
		list:scroll(math.floor(count * newScroll + 1) - list.itemIndex)
	end
end

local r = 8
local smoothingFactor = 0.8
local prevBarHeights = {}

---@param frequencies ffi.ctype*
---@param count number
---@param w number
---@param h number
function gyatt.spectrum(frequencies, count, w, h)
	for i = 0, count, 1 do
		local freq = frequencies[i]
		local power = count / (i + 1)
		local logFreq = math.log(freq + 1, power)
		local logHeight = freq + logFreq

		local rw = w / (count - 1)
		local x = i * rw
		local rh = math.max(r, logHeight * (h / 2))

		if prevBarHeights[i] then
			rh = prevBarHeights[i] * smoothingFactor + rh * (1 - smoothingFactor)
		end
		prevBarHeights[i] = rh

		local y = h - rh + r
		love.graphics.rectangle("fill", x, y, rw, rh, r, r)
	end
end

return gyatt
