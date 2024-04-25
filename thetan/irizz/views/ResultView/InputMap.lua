local InputMap = require("thetan.gyatt.InputMap")

local ResultInputMap = InputMap + {}

function ResultInputMap:createBindings(view)
	self.view = {
		["retry"] = function()
			view:play("retry")
		end,
		["watchReplay"] = function()
			view:play("replay")
		end,
		["submitScore"] = function()
			view:submitScore()
		end,
	}
end

return ResultInputMap
