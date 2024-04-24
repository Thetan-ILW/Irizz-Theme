local class = require("class")

---@class irizz.ActionModel
local ActionModel = class()

---@enum VimMode
local vimModes = {
	normal = "Normal",
	insert = "Insert",
}

---@type "vim" | "keyboard"
local inputMode = "keyboard"
---@type VimMode
local vimMode = vimModes.normal

---@type string?
local currentAction = nil
local currentVimNode = {}

local comboActions = {} -- Mod + key + ..
local operationsTree = {} -- Tree of keys
local singleKeyActions = {} -- key

local bufferTime = 0.2
local keyPressTimestamps = {}
local keysDown = {}
local modKeysDown = {}
local modKeysList = {
	lctrl = true,
	rctrl = true,
	lshift = true,
	rshift = true,
	lgui = true,
	lalt = true,
	ralt = true,
}

function ActionModel:new(configModel)
	self.configModel = configModel
end

local function buildOperationsTree(actions)
	local tree = {}
	for action, t in pairs(actions) do
		if t.op then
			local keys = t.op
			local node = tree
			for _, key in ipairs(keys) do
				node[key] = node[key] or {}
				node = node[key]
			end
			node.action = action
		end
	end
	return tree
end

function ActionModel:load()
	local configs = self.configModel.configs

	local actions

	if configs.irizz.vimMotions then
		inputMode = "vim"
		actions = configs.vim_keybinds
	else
		inputMode = "keyboard"
		actions = configs.keybinds
	end

	operationsTree = buildOperationsTree(actions)
	currentVimNode = operationsTree

	for actionName, action in pairs(actions) do
		if type(action) == "string" then
			singleKeyActions[action] = actionName
		end
	end

	-- Do the same ^^^ for combinations
end

---@return string?
function ActionModel.getAction()
	return currentAction
end

---@param action string
---@return boolean
function ActionModel.consumeAction(action)
	if currentAction == action then
		currentAction = nil
		return true
	end

	return false
end

local modFormat = {
	lctrl = "CTRL",
	rctrl = "CTRL",
	lshift = "SHIFT",
	rshift = "SHIFT",
	lalt = "ALT",
	ralt = "ALT",
}

---@return boolean
function ActionModel.isModKeyDown()
	local isDown = false

	for _, down in pairs(modKeysDown) do
		isDown = isDown or down
	end

	return isDown
end

---@return boolean
function ActionModel.isVimMode()
	return "vim" == inputMode
end

---@return VimMode
function ActionModel.getVimMode()
	return vimMode
end

---@param mode VimMode
function ActionModel.setVimMode(mode)
	vimMode = mode
end

---@return boolean
function ActionModel.isInsertMode()
	return vimMode == vimModes.insert
end

function ActionModel.resetInputs()
	modKeysDown = {}
	keysDown = {}
	keyPressTimestamps = {}
	currentAction = nil
end

function ActionModel.inputchanged(event)
	local key = event[3]
	local state = event[4]

	if modKeysList[key] then
		modKeysDown[key] = state
		return
	end

	keysDown[key] = state
end

---@param key string
---@return boolean
---@return string?
-- Returns true if current node is deep in the tree.
-- Second argument is an action name
local function handleOperations(key)
	local new_node = currentVimNode[key]

	local found_new = false
	local action = nil

	if new_node then
		currentVimNode = new_node
		found_new = true
	else
		ActionModel.resetInputs()
		currentVimNode = operationsTree
	end

	if currentVimNode.action then
		action = currentVimNode.action
		currentVimNode = operationsTree
	end

	return found_new, action
end

function ActionModel.keyPressed(event)
	local key = event[2]
	keyPressTimestamps[key] = event.time

	if ActionModel.isModKeyDown() then
		return false
	end

	if inputMode == "keyboard" then
		return
	end

	if ActionModel.isInsertMode() and key ~= "escape" then
		return
	end

	local in_tree, action = handleOperations(key)

	if action then
		currentAction = action
		return
	end

	if in_tree then
		return
	end

	action = singleKeyActions[key]

	if action then
		currentAction = action
		return
	end
end

-------------------------------

function ActionModel:getGroup(groupName)
	return --actions[groupName]
end

local order = {
	global = {
		"quit",
		"increaseVolume",
		"decreaseVolume",
		"showChartInfo",
		"showKeybinds",
		"insertMode",
		"normalMode",
	},

	largeList = {
		"up",
		"down",
		"up10",
		"down10",
		"toStart",
		"toEnd",
	},

	smallList = {
		"up",
		"down",
	},

	songSelect = {
		"play",
		"autoPlay",
		"showMods",
		"showSkins",
		"showFilters",
		"showInputs",
		"showMultiplayer",
		"showKeybinds",
		"openEditor",
		"openResult",
		"decreaseTimeRate",
		"increaseTimeRate",
		"random",
		"undoRandom",
		"clearSearch",
		"moveScreenLeft",
		"moveScreenRight",
		"pauseMusic",
	},

	resultScreen = {
		"watchReplay",
		"retry",
		"submitScore",
	},
}

---@param groupName string
---@param localization string[]
function ActionModel:formatGroup(groupName, localization)
	local t = {}
	local group = actions[groupName]

	for _, actionName in ipairs(order[groupName]) do
		local action = localization[actionName] or "IDIOT"
		local binding = group[actionName]

		if type(binding) == "string" then
			table.insert(t, { action, binding })
		elseif type(binding) == "table" then
			if binding.mod then
				table.insert(t, { action, modFormat[binding.mod[1]] .. " + " .. table.concat(binding, " + ", 1) })
			elseif binding.op then
				table.insert(t, { action, binding.op })
			end
		end
	end

	return t
end

return ActionModel
