local gfx_util = require("gfx_util")
local ScrollBar = require("thetan.irizz.imgui.ScrollBar")

local gyatt = {}

gyatt.vimMode = "Normal"
gyatt.baseline = gfx_util.printBaseline
gyatt.frame = gfx_util.printFrame

local modKeysList = {
	lctrl = true,
	rctrl = true,
	lshift = true,
	rshift = true
}

local modKeysDown = {}
local keysDown = {}
local keyPressTimestamps = {}
local bufferTime = 0.8

function gyatt.inputchanged(event)
    local key = event[3]
    local state = event[4]

	if modKeysList[key] then
		modKeysDown[key] = state
		return
	end

	keysDown[key] = state
end

function gyatt.keypressed(event)
	keyPressTimestamps[event[1]] = event.time
end

function gyatt.isModKeyDown()
	local isDown = false

	for _, down in pairs(modKeysDown) do
		isDown = isDown or down
	end

	return isDown
end

---@param action string | table
---@return boolean
function gyatt.actionPressed(action)
	local currentTime = love.timer.getTime()

	if type(action) == "string" then
        local timeStamp = keyPressTimestamps[action]
        local pressed = timeStamp and currentTime - timeStamp <= bufferTime

		if pressed then
			keyPressTimestamps[action] = -1
			return true
		end

		return false
    end

	local modKeys = action[1]
	local modKeyDown = false
    for _, k in ipairs(modKeys) do
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
function gyatt.actionDown(action)
	if type(action) == "string" then
		if gyatt.isModKeyDown() then
			return false
		end

		return keysDown[action]
	end

	local modKeys = action[1]
	local modKeyDown = false
    for _, k in ipairs(modKeys) do
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
