IRIZZ_VERSION = "0.1.9a-alpha"

local IrizzTheme = {
	name = "thetan.IrizzTheme",
	version = IRIZZ_VERSION
}

function IrizzTheme:init(mods)
	love.errhand = require("thetan.irizz.errhand")
	MODS = mods
	require("thetan.irizz.patches")
end

return IrizzTheme
