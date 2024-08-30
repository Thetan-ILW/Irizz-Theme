local gyatt = require("thetan.gyatt")

local ui = {}

local gfx = love.graphics

local shadow = { 0, 0, 0, 0.7 }

---@param text string
---@param x number
---@param y number
---@param w number
---@param h number
---@param ax "left" | "center" | "right"
---@param ay "top" | "center" | "bottom"
function ui.frameWithShadow(text, x, y, w, h, ax, ay)
	local r, g, b, a = gfx.getColor()

	gfx.push()
	gfx.setColor(shadow)
	gyatt.frame(text, x, y + 2, w, h, ax, ay)
	gfx.pop()

	gfx.setColor({ r, g, b, a })
	gyatt.frame(text, x, y, w, h, ax, ay)
end

---@param img love.Text
---@param x number
---@param y number
---@param w number
---@param h number
---@param ax? "left" | "center" | "right"
---@param ay? "top" | "center" | "bottom"
function ui.textFrameShadow(img, x, y, w, h, ax, ay)
	local r, g, b, a = gfx.getColor()

	gfx.push()
	gfx.setColor(shadow)
	gyatt.textFrame(img, x, y + 2, w, h, ax, ay)
	gfx.pop()

	gfx.setColor({ r, g, b, a })
	gyatt.textFrame(img, x, y, w, h, ax, ay)
end

---@param text string
---@param x number?
---@param ax string?
function ui.textWithShadow(text, x, ax)
	local r, g, b, a = gfx.getColor()

	gfx.push()
	gfx.setColor(shadow)
	gfx.translate(0, 2)
	gyatt.text(text, x, ax)
	gfx.pop()

	gfx.setColor({ r, g, b, a })
	gyatt.text(text, x, ax)
end

return ui
