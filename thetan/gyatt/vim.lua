local vim = {}

vim.mode = {
	normal = "Normal",
	insert = "Insert",
}

local enabled = true
local mode = vim.mode.normal
local operations = ""
local count = 1

function vim.isEnabled()
	return enabled
end

function vim.enable()
	enabled = true
end

function vim.disable()
	enabled = false
end

function vim.clear()
	operations = ""
end

function vim.updateOperation(key)
	if not enabled then
		return
	end

	count = tonumber(operations) or 1
	operations = operations .. key
end

function vim.getOperation()
	return operations
end

function vim.getCount()
	local c = count
	vim.clear()
	return c
end

function vim.setMode(newMode)
	vim.clear()
	mode = newMode
end

function vim.getMode()
	return mode
end

function vim.isNormalMode()
	return mode == vim.mode.normal
end

function vim.isInsertMode()
	return mode == vim.mode.insert
end

return vim
