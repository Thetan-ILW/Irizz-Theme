local gfx_util = require("gfx_util")
local imgui = require("thetan.irizz.imgui")
local just = require("just")
local ScrollBar = require("thetan.irizz.imgui.ScrollBar")

local gyatt = {}

gyatt.inputMode = "keyboard"
gyatt.baseline = gfx_util.printBaseline
gyatt.getCanvas = gfx_util.getCanvas
gyatt.separator = imgui.separator
gyatt.setSize = imgui.setSize
gyatt.button = just.button
gyatt.isOver = just.is_over
gyatt.mousePressed = just.mousepressed
gyatt.sameline = just.sameline

local textTransform = love.math.newTransform()
local textScale = 1

function gyatt.setTextScale(scale)
	textTransform = love.math.newTransform(0, 0, 0, scale, scale, 0, 0, 0, 0)
	textScale = scale
end

function gyatt.text(text, w, ax)
	love.graphics.push()
	love.graphics.applyTransform(textTransform)
	gfx_util.printFrame(text, 0, 0, (w or math.huge) / textScale, math.huge, ax or "left", "top")
	love.graphics.pop()
	just.next(0, love.graphics.getFont():getHeight() * textScale)
end

function gyatt.frame(text, x, y, w, h, ax, ay)
	w = w or math.huge
	h = h or math.huge
	love.graphics.push()
	love.graphics.applyTransform(textTransform)
	gfx_util.printFrame(text, x, y, w / textScale, h / textScale, ax, ay)
	love.graphics.pop()
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
