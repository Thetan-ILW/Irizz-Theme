local InputMap = require("thetan.gyatt.InputMap")

local ResultInputMap = InputMap + {}

function ResultInputMap:createBindings(view, a)
	self.view = {
		[a.retry] = function()
			view:play("retry")
		end,
		[a.watchReplay] = function()
			view:play("replay")
		end,
		[a.submitScore] = function()
			view:submitScore()
		end,
	}
end

return ResultInputMap
