local ListView = require("thetan.irizz.views.ListView")
local just = require("just")

local ModifierEncoder = require("sphere.models.ModifierEncoder")
local ModifierModel = require("sphere.models.ModifierModel")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors

local RoomUsersListView = ListView + {}

RoomUsersListView.rows = 5
RoomUsersListView.centerItems = false
RoomUsersListView.scrollSound = Theme.sounds.scrollSoundLargeList
RoomUsersListView.selectedItemIndex = 1

function RoomUsersListView:new(game)
	ListView:new(game)
	self.game = game
	self.font = Theme:getFonts("multiplayerView")
	self.text = {}
	self.text.noItems = ""
end

local empty = {}

function RoomUsersListView:reloadItems()
	local room = self.game.multiplayerModel.room
	self.items = room and room.users or empty
end

function RoomUsersListView:mouseClick(w, h, i) end

---@param i number
---@param w number
---@param h number
function RoomUsersListView:drawItem(i, w, h)
	local items = self.items
	local user = items[i]

	local multiplayerModel = self.game.multiplayerModel
	local room = multiplayerModel.room
	if not room then
		return
	end

	love.graphics.setColor(0.8, 0.8, 0.8, 1)
	if user.isReady then
		love.graphics.setColor(0.3, 1, 0.3, 1)
	end
	if not user.isNotechartFound then
		love.graphics.setColor(1, 0.3, 0.1, 1)
	end
	love.graphics.rectangle("fill", 0, 0, 12, h)

	if room.host_user_id == user.id then
		love.graphics.setColor(1, 0.7, 0.1, 1)
		love.graphics.rectangle("fill", 12, 0, 12, h)
	end

	love.graphics.setColor(1, 1, 1, 1)

	local name = user.name
	if user.isPlaying then
		name = name .. " (playing)"
	end

	local configModifier = user.modifiers
	if type(configModifier) == "string" then
		configModifier = ModifierEncoder:decode(configModifier)
	end
	configModifier = configModifier or {}
	local modifiers = ModifierModel:getString(configModifier)

	local title = user.notechart.title or ""
	local diffname = user.notechart.name or ""

	local description = "No overrides"
	if room.is_free_notechart then
		description = ("%s - %s"):format(title, diffname)
		if room.is_free_modifiers then
			description = description .. "\n"
		end
	end
	if room.is_free_modifiers then
		description = description .. modifiers
	end

	self:drawItemBody(w, h, i, false)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(self.font.users)
	love.graphics.translate(30, 0)
	just.text(name, math.huge)
	love.graphics.translate(0, -10)
	love.graphics.setFont(self.font.description)
	just.text(description, math.huge)

	if just.button("user" .. i .. "button", just.is_over(w, -h)) then
		local width = 200
		self.game.gameView:setContextMenu(function()
			local close = false
			just.indent(10)
			just.text(user.name)
			love.graphics.line(0, 0, 200, 0)
			if imgui.TextOnlyButton("Kick", "Kick", width, 55) then
				multiplayerModel:kickUser(user.id)
				close = true
			end
			if imgui.TextOnlyButton("Give host", "Give host", width, 55) then
				multiplayerModel:setHost(user.id)
				close = true
			end
			if imgui.TextOnlyButton("Close", "Close", width, 55) then
				close = true
			end
			return close
		end, width)
	end
end

return RoomUsersListView
