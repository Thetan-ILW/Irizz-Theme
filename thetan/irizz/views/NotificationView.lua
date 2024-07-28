local class = require("class")
local gyatt = require("thetan.gyatt")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

---@class irizz.NotificationView
---@operator call: irizz.NotificationView
local NotificationView = class()

local hide_time = 0.4
local animation_start_time = 0

local message = ""
local show_time = 0

---@type love.Font
local message_font

---@param assets irizz.IrizzAssets
function NotificationView:new(assets)
	text, font = assets.localization:get("notifications")
	assert(text and font)
end

---@param message_key string
---@param value any?
---@param params table?
function NotificationView:show(message_key, value, params)
	local messages = {
		exportToOsu = text.exportToOsu,
		volumeChanged = text.volume,
		chartStarted = text.chartStarted,
		cantChangeMods = text.cantChangeMods,
		scrollSpeedChanged = text.scrollSpeedChanged,
		offsetChanged = text.offsetChanged,
	}

	local label = messages[message_key] or message_key

	if value then
		if type(value) == "table" then
			label = label:format(unpack(value))
		else
			label = label:format(value)
		end
	end

	message = label

	local time = hide_time
	message_font = font.message

	if params then
		time = params.show_time or time

		if params.small_text then
			message_font = font.smallText
		end
	end

	show_time = love.timer.getTime() + time
	animation_start_time = show_time - 0.1
end

local gfx = love.graphics

function NotificationView:draw()
	local current_time = love.timer.getTime()

	if current_time > show_time then
		return
	end

	gfx.origin()
	local ww, wh = love.graphics.getDimensions()

	local w = message_font:getWidth(message) + 30
	local h = message_font:getHeight() + 40

	local previousCanvas = gfx.getCanvas()
	local layer = gyatt.getCanvas("notification")
	gfx.setCanvas({ layer, stencil = true })
	gfx.clear()

	gfx.translate((ww / 2) - (w / 2), ((wh / 2) - (h / 2)))
	ui:panel(w, h)

	gfx.origin()
	gfx.setColor(colors.ui.text)
	gfx.setFont(message_font)
	gyatt.frame(message, 0, 0, ww, wh, "center", "center")

	gfx.setCanvas({ previousCanvas, stencil = true })

	local alpha = 1 - ((current_time - animation_start_time) * 10)

	if alpha <= 1 then
		gfx.setColor({ alpha, alpha, alpha, alpha })
	end

	gfx.draw(layer)
end

return NotificationView
