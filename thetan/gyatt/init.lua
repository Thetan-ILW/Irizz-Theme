local gfx_util = require("gfx_util")
local just = require("just")
local math_util = require("math_util")
local ScrollBar = require("thetan.irizz.imgui.ScrollBar")

local gyatt = {}

gyatt.inputMode = "keyboard"
gyatt.getCanvas = gfx_util.getCanvas
gyatt.button = just.button
gyatt.isOver = just.is_over
gyatt.wheelOver = just.wheel_over
gyatt.mousePressed = just.mousepressed
gyatt.keyPressed = just.keypressed
gyatt.next = just.next
gyatt.sameline = just.sameline
gyatt.focus = just.focus
gyatt.textInput = just.textinput
gyatt.row = just.row
gyatt.resetJust = just.reset

local text_transform = love.math.newTransform()
local text_scale = 1
local global_scale = 1

function gyatt.setTextScale(scale)
	text_transform = love.math.newTransform(0, 0, 0, scale, scale, 0, 0, 0, 0)
	text_scale = scale
end

---@return number
function gyatt.getTextScale()
	return text_scale
end

function gyatt.scale(scale) -- For Irizz footer :|
	global_scale = scale
end

function gyatt.text(text, w, ax)
	love.graphics.push()
	love.graphics.applyTransform(text_transform)
	love.graphics.scale(global_scale, global_scale)
	gfx_util.printFrame(text, 0, 0, (w or math.huge) / (global_scale * text_scale), math.huge, ax or "left", "top")
	love.graphics.pop()

	local font = love.graphics.getFont()
	just.next(w, font:getHeight() * text_scale)
end

function gyatt.frame(text, x, y, w, h, ax, ay)
	w = w or math.huge
	h = h or math.huge
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.applyTransform(text_transform)
	love.graphics.scale(global_scale, global_scale)
	gfx_util.printFrame(text, 0, 0, w / (text_scale * global_scale), h / (text_scale * global_scale), ax, ay)
	love.graphics.pop()
end

---@param img love.Text
---@param x number
---@param y number
---@param w number
---@param h number
---@param ax? "left" | "center" | "right"
---@param ay? "top" | "center" | "bottom"
function gyatt.textFrame(img, x, y, w, h, ax, ay)
	w = w or math.huge
	h = h or math.huge
	love.graphics.push()
	love.graphics.translate(x, y)

	x = 0
	y = 0

	local iw, ih = img:getDimensions()
	iw, ih = iw * text_scale, ih * text_scale

	if ax == "center" then
		x = w / 2 - iw / 2
	elseif ax == "right" then
		x = w - iw
	end

	if ay == "center" then
		y = h / 2 - ih / 2
	elseif ay == "right" then
		y = h - ih
	end

	love.graphics.translate(x, y)
	love.graphics.draw(img, 0, 0, 0, text_scale, text_scale)
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

---@param time number
---@param interval number
---@return number
function gyatt.easeOutCubic(time, interval)
	local t = math.min(love.timer.getTime() - time, interval)
	local progress = t / interval
	return math_util.clamp(1 - math.pow(1 - progress, 3), 0, 1)
end

return gyatt
