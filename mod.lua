IRIZZ_VERSION = "0.4"

local IrizzTheme = {
	name = "thetan.IrizzTheme",
	version = IRIZZ_VERSION,
}

function IrizzTheme:init(mods)
	love.errhand = require("thetan.skibidi.errhand")
	MODS = mods
	require("thetan.skibidi.patches")
end

return IrizzTheme
