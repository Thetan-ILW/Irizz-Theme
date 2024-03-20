local IrizzTheme = {
	name = "thetan.IrizzTheme",
	verison = "0.1.1"
}

function IrizzTheme:init(mods)
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
