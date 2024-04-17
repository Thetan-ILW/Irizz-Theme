local gyatt = require("thetan.gyatt")

local Theme = require("thetan.irizz.views.Theme")
local Text = Theme.textNotification
local Color = Theme.colors
local font

local NotificationView = {}

local hide_time = 0.4

local message = ""
local show_time = 0

local messages = {
	volumeChanged = Text.volume,
}

function NotificationView:init()
	font = Theme:getFonts("notifications")
end

---@param message_key string
---@param value any
function NotificationView:show(message_key, value)
	local text = messages[message_key]

	if value then
		text = text:format(value)
	end

	message = text
	show_time = love.timer.getTime() + hide_time
end

local gfx = love.graphics

function NotificationView:draw()
	if love.timer.getTime() > show_time then
		return
	end

	gfx.origin()
	local ww, wh = love.graphics.getDimensions()

	local w = font.message:getWidth(message) + 30
	local h = font.message:getHeight() + 30

	gfx.translate((ww / 2) - (w / 2), ((wh / 2) - (h / 2)))
	Theme:panel(w, h)

	gfx.origin()
	gfx.setColor(Color.text)
	gfx.setFont(font.message)
	gyatt.frame(message, 0, 0, ww, wh, "center", "center")
end

return NotificationView
