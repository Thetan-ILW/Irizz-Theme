IRIZZ_VERSION = "0.1.3-alpha"

local IrizzTheme = {
	name = "thetan.IrizzTheme",
	version = IRIZZ_VERSION
}

function IrizzTheme:init(mods)
	love.errhand = require("thetan.irizz.errhand")
	MODS = mods
	require("thetan.irizz.patches")
	PartyModeActivated = false
	for _, mod in ipairs(mods) do
		if mod.instance then
			if mod.instance.name == "thetan.bass" then
				PartyModeActivated = true
				break
			end
		end
	end
end

return IrizzTheme
