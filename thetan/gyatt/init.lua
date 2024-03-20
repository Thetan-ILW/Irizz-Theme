local ScrollBar = require("thetan.irizz.imgui.ScrollBar")

local gyatt = {}

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

---@param frequencies ffi.ctype*
---@param count number
---@param w number
---@param h number
function gyatt.specter(frequencies, count, w, h)
	love.graphics.setColor({ 1, 1, 1, 0.5 })

	for i = 0, count, 1 do
		local freq = frequencies[i]
		local logFreq = math.log(freq + 1)
		local logHeight = freq + logFreq ^ 2
		love.graphics.rectangle("fill", i * (w / count), h, w / count, logHeight * -(h / 2))
	end
end

return gyatt
