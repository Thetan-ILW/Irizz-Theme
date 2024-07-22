local class = require("class")

---@class skibidi.ActionModel
---@operator call: skibidi.ActionModel
local ActionModel = class()

---@enum VimMode
local vimModes = {
	normal = "Normal",
	insert = "Insert",
}

local disabled = false

---@type "vim" | "keyboard"
local inputMode = "keyboard"
---@type VimMode
local vimMode = vimModes.normal

---@type string?
local currentAction = nil
local currentDownAction = nil
local count = ""
local currentVimNode = {}

local comboActions = {} -- [keyCombo] = action_name
local operationsTree = {} -- [key] = [key, action_name] Tree of keys
local singleKeyActions = {} -- [key] = action_name

local currentConfig = {}

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

local modFormat = {
	lctrl = "ctrl",
	rctrl = "ctrl",
	lshift = "shift",
	rshift = "shift",
	lalt = "alt",
	ralt = "alt",
}

function ActionModel:new(configModel)
	self.configModel = configModel
	love.keyboard.setKeyRepeat(true)
end

local function getComboString(t)
	for i, v in ipairs(t) do
		local formatted = modFormat[v] or v
		t[i] = formatted
	end

	table.sort(t)
	return table.concat(t, "+")
end

function ActionModel:updateActions()
	local configs = self.configModel.configs

	if configs.irizz.vimMotions then
		inputMode = "vim"
		currentConfig = configs.vim_keybinds_v2
	else
		inputMode = "keyboard"
		currentConfig = configs.keybinds_v2
	end

	for actionName, action in pairs(currentConfig) do
		if type(action) == "string" then
			singleKeyActions[action] = actionName
		end

		if type(action) == "table" then
			if action.op then
				local keys = action.op
				local node = operationsTree
				for _, key in ipairs(keys) do
					node[key] = node[key] or {}
					node = node[key]
				end
				node.action = actionName
			end

			if action.mod then
				comboActions[getComboString(action.mod)] = actionName
			end
		end
	end

	currentVimNode = operationsTree
end

function ActionModel:load()
	self:updateActions()
end

---@return string?
function ActionModel.getAction()
	return currentAction
end

function ActionModel.getCount()
	return tonumber(count) or 1
end

function ActionModel.resetAction()
	count = ""
	currentAction = nil
end

---@param action string
---@return boolean
function ActionModel.consumeAction(action)
	if currentAction == action then
		ActionModel.resetAction()
		return true
	end

	return false
end

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

local function getDownModAction()
	local keys = {}
	local ctrl_down = false

	for k, _ in pairs(modKeysDown) do
		if ctrl_down then
			goto continue
		end

		table.insert(keys, k)

		if k == "lctrl" or k == "rctrl" then
			ctrl_down = true
		end

		::continue::
	end

	for k, _ in pairs(keysDown) do
		table.insert(keys, k)
	end

	return comboActions[getComboString(keys)]
end

local function getDownAction()
	for k, _ in pairs(keysDown) do
		local action = singleKeyActions[k]

		if action then
			return action
		end
	end

	return nil
end

---@param event table
-- Accepts keyboard events and finds which actions is down
function ActionModel.inputChanged(event)
	if disabled then
		return
	end

	local key = event[3]
	local state = event[4]

	if modKeysList[key] then
		modKeysDown[key] = state or nil
	else
		keysDown[key] = state or nil
	end

	if ActionModel.isModKeyDown() then
		currentDownAction = getDownModAction()
		return
	end

	currentDownAction = getDownAction()
end

---@param key string
---@param final boolean?
---@return string?
local function nextInTree(key, final)
	local new_node = currentVimNode[key]

	local action = nil

	if new_node then
		currentVimNode = new_node
	else
		currentVimNode = operationsTree

		if not final then -- makes inputs like "ooi" work
			return nextInTree(key, true)
		end
	end

	if currentVimNode.action then
		action = currentVimNode.action
		currentVimNode = operationsTree
	end

	return action
end

local function getComboAction()
	local keys = {}
	local ctrl_down = false
	local current_time = love.timer.getTime()

	for k, _ in pairs(modKeysDown) do
		if ctrl_down then
			goto continue
		end

		table.insert(keys, k)

		if k == "lctrl" or k == "rctrl" then
			ctrl_down = true
		end

		::continue::
	end

	for key, time in pairs(keyPressTimestamps) do
		if time + bufferTime > current_time then
			table.insert(keys, key)
		else
			keyPressTimestamps[key] = nil
		end
	end

	return comboActions[getComboString(keys)]
end

function ActionModel.keyPressed(event)
	if disabled then
		return
	end

	local key = event[2]

	if tonumber(key) and not ActionModel.isInsertMode() then
		count = count .. key
	end

	if not modKeysList[key] then
		keyPressTimestamps[key] = event.time
	end

	if ActionModel.isModKeyDown() then
		currentAction = getComboAction()
		return
	end

	if inputMode == "keyboard" then
		currentAction = singleKeyActions[key]
		return
	end

	if ActionModel.isInsertMode() and key ~= "escape" then
		return
	end

	local action = nextInTree(key)

	if action then
		currentAction = action
		return
	end

	currentAction = singleKeyActions[key]
end

---@param name string
---@return boolean
function ActionModel.isActionDown(name)
	return currentDownAction == name
end

function ActionModel.enable()
	disabled = false
end

function ActionModel.disable()
	disabled = true
	ActionModel.resetInputs()
end

function ActionModel.isEnabled()
	return not disabled
end

-------------------------------

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
---@return table
function ActionModel:formatGroup(groupName, localization)
	local t = {}

	for _, actionName in ipairs(order[groupName]) do
		local action = localization[actionName] or "IDIOT"
		local binding = currentConfig[actionName]

		if type(binding) == "string" then
			table.insert(t, { action, binding })
		elseif type(binding) == "table" then
			if binding.mod then
				table.insert(t, { action, table.concat(binding.mod, " + ", 1) })
			elseif binding.op then
				table.insert(t, { action, table.concat(binding.op) })
			end
		end
	end

	return t
end

return ActionModel
