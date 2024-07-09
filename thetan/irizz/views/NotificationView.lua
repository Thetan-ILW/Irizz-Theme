local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Text = Theme.textNotification
local Color = Theme.colors
local font

local NotificationView = {}

local hide_time = 0.4
local animation_start_time = 0

local message = ""
local show_time = 0
local message_font

local messages = {
	exportToOsu = Text.exportToOsu,
	volumeChanged = Text.volume,
	chartStarted = Text.chartStarted,
	cantChangeMods = Text.cantChangeMods,
}

function NotificationView:init()
	font = Theme:getFonts("notifications")
end

---@param message_key string
---@param value any?
---@param params table?
function NotificationView:show(message_key, value, params)
	local text = messages[message_key] or message_key

	if value then
		if type(value) == "table" then
			text = text:format(unpack(value))
		else
			text = text:format(value)
		end
	end

	message = text

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
	Theme:panel(w, h)

	gfx.origin()
	gfx.setColor(Color.text)
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
