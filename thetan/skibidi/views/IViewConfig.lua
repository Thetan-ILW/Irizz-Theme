local class = require("class")

---@class IViewConfig
---@operator call: IViewConfig
local IViewConfig = class()

function IViewConfig:resolutionUpdated() end
function IViewConfig:draw() end

return IViewConfig
