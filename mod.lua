local IrizzTheme = {
	name = "thetan.IrizzTheme",
	verison = "0.1.1"
}

function IrizzTheme:init()
	require("thetan.irizz.patches")
end

return IrizzTheme
